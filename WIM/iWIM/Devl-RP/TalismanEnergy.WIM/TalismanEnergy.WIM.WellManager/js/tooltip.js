var tooltip=function(){
	var id = 'tt';
	var top = 1;
	var left = 6;
	var minTop = 5;
	var minLeft = 5;
	var speed = 10;
	var timer = 20;
	var endalpha = 95;
	var alpha = 0;
	var tt,h,w;
	var ie = document.all ? true : false;
	return{
		show:function(v,wid){
			if(tt == null){
				tt = document.createElement('div');
				tt.setAttribute('id',id);
				document.body.appendChild(tt);
				tt.style.opacity = 0;
				tt.style.filter = 'alpha(opacity=0)';
			}
    		document.onmousemove = this.pos;
			tt.style.display = 'block';
			tt.innerHTML = v;
			tt.style.width = wid ? wid + 'px' : 'auto';
			h = parseInt(tt.offsetHeight) + top;
			w = parseInt(tt.offsetWidth) + left;
			clearInterval(tt.timer);
			tt.timer = setInterval(function(){tooltip.fade(1)},timer);
		},
		pos:function(e){
			var y = ie ? event.clientY + document.documentElement.scrollTop : e.pageY;
			var x = ie ? event.clientX + document.documentElement.scrollLeft : e.pageX;
			tt.style.top = Math.max((y - h),minTop) + 'px';
			tt.style.left = Math.max((x - w),minLeft)  + 'px';
		},
		fade:function(d){
			var a = alpha;
			if((a != endalpha && d == 1) || (a != 0 && d == -1)){
				var i = speed;
				if(endalpha - a < speed && d == 1){
					i = endalpha - a;
				}else if(alpha < speed && d == -1){
					i = a;
				}
				alpha = a + (i * d);
				tt.style.opacity = alpha * .01;
				tt.style.filter = 'alpha(opacity=' + alpha + ')';
			}else{
				clearInterval(tt.timer);
				if(d == -1){tt.style.display = 'none'}
			}
		},
		hide:function(){
			clearInterval(tt.timer);
			tt.timer = setInterval(function(){tooltip.fade(-1)},timer);
		}
	};
}();