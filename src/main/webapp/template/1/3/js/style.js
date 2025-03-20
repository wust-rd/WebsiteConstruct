$(function () {
    new WOW({
        mobile: false
    }).init();

    $('.sc-form').find('form').submit(function () {
        var val = $(this).find('input').val();
        if (!val) {
            alert('请输入关键字');
            return false
        }
    });

    $('.menu-btn').on('click', function () {
        $('.header').find('.nav').toggle();
    });

    $('.sc-btn').on('click', function () {
        $('.header').find('.sc-form').toggle();
    });

    if ($(window).width() > 991) {
        $('.dropdown').hover(function () {
            $(this).addClass('open');
        }, function () {
            $(this).removeClass('open');
        });
    } else {
        $('.dropdown').find('.arr').on('click', function () {
            $(this).parent().toggleClass('open');
        });
    }

    $('.lanmu-title').on('click', function () {
        var $ul = $('.lanmu').find('ul');
        if ($ul.is(':hidden')) {
            $ul.slideDown(300);
        } else {
            $ul.slideUp(300);
        }
    });

    // 右侧滑动返回顶部
    $('.kf .kf-side').click(function(){
        //$('.kf').animate({ right: '-208' }, "slow");
        var rt = $('.kf').css("right");
        //alert(rt);
        var num = parseInt(rt);
        //alert(num);
        if(num < 0){
            $('.kf').animate({ right: '20px' }, "slow");
            $('.kf .kf-side span.arrow').addClass('on');
        }else{
            $('.kf').animate({ right: '-208px' }, "slow");
            $('.kf .kf-side span.arrow').removeClass('on');
        }
    });
    $('.kt-top span.close').click(function(){
        $('.kf').animate({ right: '-208px' }, "slow");
    });

    $('.kf .backTop').click(function() {
        $("html,body").stop().animate({ scrollTop: '0' }, 500);
    });

    $('.sp_nav').on('click', function () {
        var $box = $('.sp_nav-box');
        if (!$box.is(':visible')) {
            $('body').addClass('sp_nav_body');
            $('.header').addClass('sp_nav_se');
            $box.stop().fadeIn();
        } else {
            $('body').removeClass('sp_nav_body');
            $('.header').removeClass('sp_nav_se');
            $box.stop().fadeOut();
        }
    });

    $('.oneform').on('click', '.close', function() {
        $('.oneform').stop().slideUp();
    });
    $('.in-partone').on('click', 'a', function(e) {
        e.preventDefault();
        $('.oneform').stop().slideDown();
    });
});

function tabsSwiper(menu, con, allowTouchMove) {
    var swiper = new Swiper(con, {
        speed: 500,
        spaceBetween: 10,
        autoHeight: true,
        allowTouchMove: !allowTouchMove,
        on: {
            slideChangeTransitionStart: function () {
                $(menu).find('li').eq(this.activeIndex).addClass('active').siblings().removeClass('active');
            }
        }
    });
    $(menu).on('click', 'li', function (e) {
        $(this).addClass('active').siblings().removeClass('active');
        swiper.slideTo($(this).index());
    });
}
