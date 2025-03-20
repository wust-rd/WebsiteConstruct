<!DOCTYPE html>
<html>
<head>
    <title>分类</title>
    <#include "../../include/head-file.ftl">
    <script src="${base}/static/plugins/clipboard/clipboard.js"></script>
</head>
<body>
<div id="index" class="ms-index" v-cloak>
    <el-header class="ms-header" height="50px">
        <el-col :span=12>
            <@shiro.hasPermission name="cms:category:save">
                <el-button type="primary" class="el-icon-plus" size="default" @click="save()">新增</el-button>
            </@shiro.hasPermission>
            <@shiro.hasPermission name="cms:category:del">
                <el-button type="danger" class="el-icon-delete" size="default" @click="del(selectionList)"
                           :disabled="!selectionList.length">删除
                </el-button>
            </@shiro.hasPermission>
        </el-col>
    </el-header>
    <el-main class="ms-container">
        <el-table ref="multipleTable" :indent="6"
                  height="calc(100vh - 100px)"
                  border :data="dataList"
                  row-key="id"
                  v-loading="loading"
                  :default-expand-all=true
                  :tree-props="{children: 'children'}"
                  tooltip-effect="dark"
                  @selection-change="handleSelectionChange">
            <template #empty>
                {{emptyText}}
            </template>
            <el-table-column type="selection" width="40"></el-table-column>
            <el-table-column label="编号" width="100" prop="id" show-overflow-tooltip>
                <template #title>编号
                    <el-popover placement="top-start" title="提示" trigger="hover">
                        标签：<a href="http://doc.mingsoft.net/mcms/biao-qian/lan-mu-lie-biao-ms-channel.html"
                              target="_blank">${'$'}{field.id}</a>
                        <template #reference>
                            <i class="el-icon-question" ></i>
                        </template>
                    </el-popover>
                </template>
                <template #default="scope">
                    <span style="cursor: pointer" class="copyBtn" :data-clipboard-text="scope.row.id"
                          @click="copyContent(true)">{{scope.row.id}}</span>
                </template>
            </el-table-column>
            <el-table-column label="标题" align="left" prop="categoryTitle" :show-overflow-tooltip="true">
            </el-table-column>
            <el-table-column label="副标题" align="left" prop="categoryShortTitle" width="120" :show-overflow-tooltip="true">
            </el-table-column>
            <el-table-column label="类型" align="center" prop="categoryType" :formatter="categoryTypeFormat" width="70">
            </el-table-column>
            <el-table-column label="排序" align="center" prop="categorySort" width="70">
            </el-table-column>
            <el-table-column label="链接地址" align="left" prop="categoryPath" min-width="200" show-overflow-tooltip>
                <template #default="scope">
                    <span v-if="scope.row.categoryType == '1' || scope.row.categoryType == '2'" style="cursor: pointer"
                          class="copyBtn" :data-clipboard-text="scope.row.url"
                          @click="copyContent">{{scope.row.url}}</span>
                    <span v-if="scope.row.categoryType == '3'" style="cursor: pointer" class="copyBtn"
                          :data-clipboard-text="scope.row.categoryDiyUrl" @click="copyContent">{{scope.row.categoryDiyUrl}}</span>
                </template>
            </el-table-column>
            <el-table-column label="列表地址" align="left" prop="categoryListUrl" width="100" show-overflow-tooltip>
            </el-table-column>
            <el-table-column label="内容地址" align="left" prop="categoryUrl" width="100" show-overflow-tooltip>
                <template #default="scope">
                    {{scope.row.categoryType == '1'?scope.row.categoryUrl:''}}
                    {{scope.row.categoryType == '2'?scope.row.categoryUrl:''}}
                </template>
            </el-table-column>
            <el-table-column label="栏目属性" align="left" prop="categoryFlag" width="80" show-overflow-tooltip>
                <template #default="scope">
                    {{getDictLabel(scope.row.categoryFlag)}}
                </template>
            </el-table-column>
            <el-table-column label="操作" width="240" align="center">
                <template #default="scope">
                    <el-link type="primary" :underline="false" v-if="scope.row.categoryType != '3'" @click="preview(scope.row)">预览</el-link>
                    <@shiro.hasPermission name="cms:category:save">
                        <el-link type="primary" :underline="false" @click="save(scope.row.id, scope.row.id)"><i
                                    class="el-icon-plus"></i>子栏目
                        </el-link>
                    </@shiro.hasPermission>
                    <@shiro.hasPermission name="cms:category:save">
                        <el-link type="primary" :underline="false" @click="copyCategory(scope.row.id)">克隆</el-link>
                    </@shiro.hasPermission>
                    <@shiro.hasPermission name="cms:category:update">
                        <el-link type="primary" :underline="false" @click="save(scope.row.id)">编辑</el-link>
                    </@shiro.hasPermission>
                    <@shiro.hasPermission name="cms:category:del">
                        <el-link type="primary" :underline="false" @click="del([scope.row])">删除</el-link>
                    </@shiro.hasPermission>
                </template>
            </el-table-column>
        </el-table>
    </el-main>
</div>
</body>

</html>
<script>
    "use strict";

    var indexVue = new _Vue({
        el: '#index',
        data: function () {
            return {
                //分类列表
                dataList: [],
                //分类列表选中
                selectionList: [],
                //加载状态
                loading: true,
                //提示文字
                emptyText: '',
                categoryFlagOptions: [],
                manager: ms.manager,
                loadState: false,
                categoryTypeOptions: [{
                    "value": "1",
                    "label": "列表"
                }, {
                    "value": "2",
                    "label": "单篇"
                }, {
                    "value": "3",
                    "label": "链接"
                }],
                //搜索表单
                form: {
                    // 栏目管理名称
                    categoryTitle: '',
                    // 栏目管理名称
                    categoryShortTitle: '',
                    // 所属栏目
                    categoryId: '',
                    // 栏目管理属性
                    categoryType: '2',
                    // 自定义顺序
                    categorySort: 0,
                    // 列表模板
                    categoryListUrl: '',
                    // 内容模板
                    categoryUrl: '',
                    // 栏目管理关键字
                    categoryKeyword: '',
                    // 栏目管理描述
                    categoryDescrip: '',
                    // 缩略图
                    categoryImg: [],
                    // 自定义链接
                    categoryDiyUrl: '',
                    // 栏目管理的内容模型id
                    mdiyModelId: ''
                }
            }
        },
        methods: {
            //复制栏目
            copyCategory: function (id) {
                var that = this;
                ms.http.get(ms.manager + "/cms/category/copyCategory.do", {
                    id: id
                }).then(function (res) {
                    if (res.result) {
                        that.$notify({
                            title: '成功',
                            message: '复制成功',
                            type: 'success'
                        });
                        that.list();
                    } else {
                        that.$notify({
                            title: '失败',
                            message: res.msg,
                            type: 'warning'
                        });
                    }
                });
            },
            //应用子栏目模板
            updateTemplate: function (id) {
                var that = this;
                ms.http.get(ms.manager + "/cms/category/updateTemplate.do", {
                    id: id
                }).then(function (res) {
                    if (res.result) {
                        that.$notify({
                            title: '成功',
                            message: '应用成功',
                            type: 'success'
                        });
                        that.list();
                    } else {
                        that.$notify({
                            title: '失败',
                            message: res.msg,
                            type: 'warning'
                        });
                    }
                });
            },
            //根据字典数据值获取字典标签名
            getDictLabel: function (v) {
                var that = this;
                var labels = [];
                if (v) {
                    v.split(",").forEach(function (item) {
                        for (var key in that.categoryFlagOptions) {
                            if (item == that.categoryFlagOptions[key].dictValue) {
                                labels.push(that.categoryFlagOptions[key].dictLabel);
                                break;
                            }
                        }
                    });
                }
                return labels.toString();
            },
            //查询列表
            list: function () {
                var that = this;
                this.loadState = false;
                this.loading = true;
                ms.http.get(ms.manager + "/cms/category/list.do").then(function (res) {
                    if (that.loadState) {
                        that.loading = false;
                    } else {
                        that.loadState = true;
                    }

                    if (!res.result || res.data.total <= 0) {
                        that.emptyText = '暂无数据';
                        that.dataList = [];
                    } else {
                        that.emptyText = '';
                        that.dataList = ms.util.treeData(res.data.rows, 'id', 'categoryId', 'children');
                    }
                });
                setTimeout(function () {
                    if (that.loadState) {
                        that.loading = false;
                    } else {
                        that.loadState = true;
                    }
                }, 500);
            },
            copyContent: function (id) {
                var msg = "链接地址已保存到剪切板";
                if (id == true) {
                    msg = "编号已保存到剪切板";
                }
                var clipboard = new ClipboardJS('.copyBtn');
                var self = this;
                clipboard.on('success', function (e) {
                    self.$notify({
                        title: '提示',
                        message: msg,
                        type: 'success'
                    });
                    clipboard.destroy();
                });
            },
            //分类列表选中
            handleSelectionChange: function (val) {
                this.selectionList = val;
            },
            //删除
            del: function (row) {
                var that = this;
                that.$confirm('此操作将永久删除分类和分类下的文章, 是否继续?', '提示', {
                    confirmButtonText: '确定',
                    cancelButtonText: '取消',
                    type: 'warning'
                }).then(function () {
                    ms.http.post(ms.manager + "/cms/category/delete.do", row.length ? row : [row], {
                        headers: {
                            'Content-Type': 'application/json'
                        }
                    }).then(function (res) {
                        if (res.result) {
                            that.$notify({
                                title: '成功 ',
                                type: 'success',
                                message: '删除成功!'
                            }); //删除成功，刷新列表

                            that.list();
                        } else {
                            that.$notify({
                                title: '失败',
                                message: res.msg,
                                type: 'warning'
                            });
                        }
                    });
                })
            },
            //预览栏目
            preview: function (row) {
                window.open(row["url"]);
            },
            //获取categoryFlag数据源
            categoryFlagOptionsGet: function () {
                var that = this;
                ms.http.get(ms.base + '/mdiy/dict/list.do', {
                    dictType: '栏目属性',
                    pageSize: 99999
                }).then(function (res) {
                    if (res.result) {
                        res = res.data;
                        that.categoryFlagOptions = res.rows;
                    }
                });
            },
            //表格数据转换
            categoryTypeFormat: function (row, column, cellValue, index) {
                var value = "";

                if (cellValue) {
                    var data = this.categoryTypeOptions.find(function (value) {
                        return value.value == cellValue;
                    });

                    if (data && data.label) {
                        value = data.label;
                    }
                }

                return value;
            },
            //新增
            save: function (id, childId) {
                if (id) {
                    // location.href = this.manager + "/cms/category/form.do?id=" + id + "&childId=" + childId;
                    ms.util.openSystemUrl("/cms/category/form.do?id=" + id + "&childId=" + childId);
                } else {
                    // location.href = this.manager + "/cms/category/form.do";
                    ms.util.openSystemUrl("/cms/category/form.do");
                }
            },
            //重置表单
            rest: function () {
                this.$refs.searchForm.resetFields();
            }
        },
        created: function () {
            /* this.categoryListUrlOptionsGet();
             this.categoryUrlOptionsGet();*/
            this.categoryFlagOptionsGet();
            this.list();
        }
    });
</script>
