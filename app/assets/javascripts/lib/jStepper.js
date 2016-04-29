// jStepper 1.5.3
!function(e){e.fn.jStepper=function(t,n,a){if(this.length>1)return this.each(function(){$(this).jStepper(t)}),this;if("string"==typeof t)return"option"===t&&(null===a&&(a=e.fn.jStepper.defaults[n]),this.data("jstepper.o")[n]=a),this;var l=e.extend({},e.fn.jStepper.defaults,t);e.metadata&&(l=e.extend({},l,this.metadata())),this.data("jstepper.o",l),l.disableAutocomplete&&this.attr("autocomplete","off"),e.isFunction(this.mousewheel)&&this.mousewheel(function(t,n){if(n>0){var a=e.Event("keydown");return a.keyCode=38,r(1,a,this),!1}if(0>n){var a=e.Event("keydown");return a.keyCode=40,r(0,a,this),!1}}),this.blur(function(){i(this,null)}),this.keydown(function(e){var t=e.keyCode;if(38===t)r(1,e,this);else if(40===t)r(0,e,this);else if("ignore"===l.overflowMode){var n=0===$(this).val().indexOf("-")?l.minValue:l.maxValue;if(n&&$(this).val().length>=n.toString().length&&(t>=48&&57>=t||t>=96&&105>=t)&&this.selectionStart===this.selectionEnd)return!1}}),this.keyup(function(e){i(this,e)});var i=function(t,n){var a=e(t),i=a.val(),r=i;l.disableNonNumeric&&(i=i.replace(/[^\d\.,\-]/gi,""),i=i.replace(/-{2,}/g,"-"),i=i.replace(/(.+)\-+/g,"$1"));var s=!1;null!==l.maxValue&&i>l.maxValue&&(i=l.maxValue,s=!0),null!==l.minValue&&""!=i&&parseFloat(i)<parseFloat(l.minValue)&&(i=l.minValue,s=!0),(c(n)===!0||null===n||s===!0)&&(i=u(i)),r!=i&&a.val(i)},r=function(t,n,a){var r,u=e(a);r=n?n.ctrlKey?l.ctrlStep:n.shiftKey?l.shiftStep:l.normalStep:l.normalStep;var s=u.val(),o=s.length-a.selectionStart,f=s.length-a.selectionEnd;s=s.replace(/,/g,"."),s=s.replace(l.decimalSeparator,"."),s+="",-1!=s.indexOf(".")&&(s=s.match(new RegExp("-{0,1}[0-9]+[\\.][0-9]*"))),s+="",-1!=s.indexOf("-")&&(s=s.match(new RegExp("-{0,1}[0-9]+[\\.]*[0-9]*"))),s+="",s=s.match(new RegExp("-{0,1}[0-9]+[\\.]*[0-9]*")),(""===s||"-"==s||null===s)&&(s=l.defaultValue),s=1===t?e.fn.jStepper.AddOrSubtractTwoFloats(s,r,!0):e.fn.jStepper.AddOrSubtractTwoFloats(s,r,!1);var m=!1;return null!==l.maxValue&&s>=l.maxValue&&(s=l.maxValue,m=!0),null!==l.minValue&&s<=l.minValue&&(s=l.minValue,m=!0),s=s.toString().replace(/\./,l.decimalSeparator),u.val(s),a.selectionStart=s.length-o,a.selectionEnd=s.length-f,i(a,n),l.onStep&&l.onStep(u,t,m),!1},u=function(e){var t=e.toString();return t=s(t),t=o(t),t=f(t),t=m(t)},s=function(e){var t=e;if(l.minDecimals>0){var n;if(-1!=t.indexOf(".")){var a=t.length-(t.indexOf(".")+1);a<l.minDecimals&&(n=l.minDecimals-a)}else n=l.minDecimals,t+=".";for(var i=1;n>=i;i++)t+="0"}return t},o=function(e){var t=e;if(l.maxDecimals>0){var n=0;-1!=t.indexOf(".")&&(n=t.length-(t.indexOf(".")+1),l.maxDecimals<n&&(t=t.substring(0,t.indexOf("."))+"."+t.substring(t.indexOf(".")+1,t.indexOf(".")+1+l.maxDecimals)))}return t},f=function(e){var t=e;return l.allowDecimals||(t=t.toString().replace(l.decimalSeparator,"."),t=t.replace(new RegExp("[\\.].+"),"")),t},m=function(e){var t=e;if(null!==l.minLength){var n=t.length;-1!=t.indexOf(".")&&(n=t.indexOf("."));var a=!1;if(-1!=t.indexOf("-")&&(a=!0,t=t.replace(/-/,"")),n<l.minLength)for(var i=1;i<=l.minLength-n;i++)t="0"+t;a&&(t="-"+t)}return t},c=function(e){var t=!1;return null!==e&&(38===e.keyCode||40===e.keyCode)&&(t=!0),t};return this},e.fn.jStepper.AddOrSubtractTwoFloats=function(e,t,n){var a=e.toString(),l=t.toString(),i="";if(a.indexOf(".")>-1||l.indexOf(".")>-1){-1===a.indexOf(".")&&(a+=".0"),-1===l.indexOf(".")&&(l+=".0");for(var r=a.substr(a.indexOf(".")+1),u=l.substr(l.indexOf(".")+1),s=a.substr(0,a.indexOf(".")),o=l.substr(0,l.indexOf(".")),f=!0;f;)r.length!==u.length?r.length<u.length?r+="0":u+="0":f=!1;for(var m=r.length,c=0;c<=r.length-1;c++)s+=r.substr(c,1),o+=u.substr(c,1);var d,h=Number(s),p=Number(o);d=n?h+p:h-p;var g=!1;0>d&&(g=!0,d=Math.abs(d)),i=d.toString();for(var v=0;v<m-i.length+1;v++)i="0"+i;i.length>=m&&(i=i.substring(0,i.length-m)+"."+i.substring(i.length-m)),g===!0&&(i="-"+i)}else i=n?Number(e)+Number(t):Number(e)-Number(t);return Number(i)},e.fn.jStepper.defaults={maxValue:null,minValue:null,normalStep:1,shiftStep:5,ctrlStep:10,minLength:null,disableAutocomplete:!0,defaultValue:1,decimalSeparator:",",allowDecimals:!0,minDecimals:0,maxDecimals:null,disableNonNumeric:!0,onStep:null,overflowMode:"default"}}(jQuery);