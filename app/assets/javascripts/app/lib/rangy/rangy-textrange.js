/**
 * Text range module for Rangy.
 * Text-based manipulation and searching of ranges and selections.
 *
 * Features
 *
 * - Ability to move range boundaries by character or word offsets
 * - Customizable word tokenizer
 * - Ignores text nodes inside <script> or <style> elements or those hidden by CSS display and visibility properties
 * - Range findText method to search for text or regex within the page or within a range. Flags for whole words and case
 *   sensitivity
 * - Selection and range save/restore as text offsets within a node
 * - Methods to return visible text within a range or selection
 * - innerText method for elements
 *
 * References
 *
 * https://www.w3.org/Bugs/Public/show_bug.cgi?id=13145
 * http://aryeh.name/spec/innertext/innertext.html
 * http://dvcs.w3.org/hg/editing/raw-file/tip/editing.html
 *
 * Part of Rangy, a cross-browser JavaScript range and selection library
 * https://github.com/timdown/rangy
 *
 * Depends on Rangy core.
 *
 * Copyright 2015, Tim Down
 * Licensed under the MIT license.
 * Version: 1.3.0-beta.1
 * Build date: 12 February 2015
 */
!function(e,t){"function"==typeof define&&define.amd?define(["./rangy-core"],e):"undefined"!=typeof module&&"object"==typeof exports?module.exports=e(require("rangy")):e(t.rangy)}(function(e){return e.createModule("TextRange",["WrappedSelection"],function(e,t){function n(e,t){function n(t,n,r){for(var i=e.slice(t,n),o={isWord:r,chars:i,toString:function(){return i.join("")}},a=0,c=i.length;c>a;++a)i[a].token=o;s.push(o)}for(var r,i,o,a=e.join(""),s=[],c=0;r=t.wordRegex.exec(a);){if(i=r.index,o=i+r[0].length,i>c&&n(c,i,!1),t.includeTrailingSpace)for(;J.test(e[o]);)++o;n(i,o,!0),c=o}return c<e.length&&n(c,e.length,!1),s}function r(e){var t=e||"",n="string"==typeof t?t.split(""):t;return n.sort(function(e,t){return e.charCodeAt(0)-t.charCodeAt(0)}),n.join("").replace(/(.)\1+/g,"$1")}function i(e){var t,n;return e?(t=e.language||Q,n={},U(n,at[t]||at[Q]),U(n,e),n):at[Q]}function o(e,t){var n=G(e,t);return t.hasOwnProperty("wordOptions")&&(n.wordOptions=i(n.wordOptions)),t.hasOwnProperty("characterOptions")&&(n.characterOptions=G(n.characterOptions,it)),n}function a(e,t){var n=lt(e,"display",t),r=e.tagName.toLowerCase();return"block"==n&&rt&&ht.hasOwnProperty(r)?ht[r]:n}function s(e){for(var t=h(e),n=0,r=t.length;r>n;++n)if(1==t[n].nodeType&&"none"==a(t[n]))return!0;return!1}function c(e){var t;return 3==e.nodeType&&(t=e.parentNode)&&"hidden"==lt(t,"visibility")}function u(e){return e&&(1==e.nodeType&&!/^(inline(-block|-table)?|none)$/.test(a(e))||9==e.nodeType||11==e.nodeType)}function d(e){return q.isCharacterDataNode(e)||!/^(area|base|basefont|br|col|frame|hr|img|input|isindex|link|meta|param)$/i.test(e.nodeName)}function l(e){for(var t=[];e.parentNode;)t.unshift(e.parentNode),e=e.parentNode;return t}function h(e){return l(e).concat([e])}function p(e){for(;e&&!e.nextSibling;)e=e.parentNode;return e?e.nextSibling:null}function f(e,t){return!t&&e.hasChildNodes()?e.firstChild:p(e)}function g(e){var t=e.previousSibling;if(t){for(e=t;e.hasChildNodes();)e=e.lastChild;return e}var n=e.parentNode;return n&&1==n.nodeType?n:null}function v(e){if(!e||3!=e.nodeType)return!1;var t=e.data;if(""===t)return!0;var n=e.parentNode;if(!n||1!=n.nodeType)return!1;var r=lt(e.parentNode,"whiteSpace");return/^[\t\n\r ]+$/.test(t)&&/^(normal|nowrap)$/.test(r)||/^[\t\r ]+$/.test(t)&&"pre-line"==r}function C(e){if(""===e.data)return!0;if(!v(e))return!1;var t=e.parentNode;return t?s(e)?!0:!1:!0}function S(e){var t=e.nodeType;return 7==t||8==t||s(e)||/^(script|style)$/i.test(e.nodeName)||c(e)||C(e)}function y(e,t){var n=e.nodeType;return 7==n||8==n||1==n&&"none"==a(e,t)}function N(){this.store={}}function m(e,t,n){return function(r){var i=this.cache;if(i.hasOwnProperty(e))return pt++,i[e];ft++;var o=t.call(this,n?this[n]:this,r);return i[e]=o,o}}function x(e,t){this.node=e,this.session=t,this.cache=new N,this.positions=new N}function T(e,t){this.offset=t,this.nodeWrapper=e,this.node=e.node,this.session=e.session,this.cache=new N}function b(){return"[Position("+q.inspectNode(this.node)+":"+this.offset+")]"}function P(){return R(),wt=new Rt}function w(){return wt||P()}function R(){wt&&wt.detach(),wt=null}function B(e,n,r,i){function o(){var e=null;return n?(e=s,c||(s=s.previousVisible(),c=!s||r&&s.equals(r))):c||(e=s=s.nextVisible(),c=!s||r&&s.equals(r)),c&&(s=null),e}r&&(n?S(r.node)&&(r=e.previousVisible()):S(r.node)&&(r=r.nextVisible()));var a,s=e,c=!1,u=!1;return{next:function(){if(u)return u=!1,a;for(var e,t;e=o();)if(t=e.getCharacter(i))return a=e,e;return null},rewind:function(){if(!a)throw t.createError("createCharacterIterator: cannot rewind. Only one position can be rewound.");u=!0},dispose:function(){e=r=null}}}function E(e,t,n){function r(e){for(var t,n,r=[],a=e?i:o,s=!1,c=!1;t=a.next();){if(n=t.character,Y.test(n))c&&(c=!1,s=!0);else{if(s){a.rewind();break}c=!0}r.push(t)}return r}var i=B(e,!1,null,t),o=B(e,!0,null,t),a=n.tokenizer,s=r(!0),c=r(!1).reverse(),u=a(c.concat(s),n),d=s.length?u.slice(Bt(u,s[0].token)):[],l=c.length?u.slice(0,Bt(u,c.pop().token)+1):[];return{nextEndToken:function(){for(var e,t;1==d.length&&!(e=d[0]).isWord&&(t=r(!0)).length>0;)d=a(e.chars.concat(t),n);return d.shift()},previousStartToken:function(){for(var e,t;1==l.length&&!(e=l[0]).isWord&&(t=r(!1)).length>0;)l=a(t.reverse().concat(e.chars),n);return l.pop()},dispose:function(){i.dispose(),o.dispose(),d=l=null}}}function O(e,t,n,r,i){var o,a,s,c,u=0,d=e,l=Math.abs(n);if(0!==n){var h=0>n;switch(t){case $:for(a=B(e,h,null,r);(o=a.next())&&l>u;)++u,d=o;s=o,a.dispose();break;case M:for(var p=E(e,r,i),f=h?p.previousStartToken:p.nextEndToken;(c=f())&&l>u;)c.isWord&&(++u,d=h?c.chars[0]:c.chars[c.chars.length-1]);break;default:throw new Error("movePositionBy: unit '"+t+"' not implemented")}h?(d=d.previousVisible(),u=-u):d&&d.isLeadingSpace&&(t==M&&(a=B(e,!1,null,r),s=a.next(),a.dispose()),s&&(d=s.previousVisible()))}return{position:d,unitsMoved:u}}function k(e,t,n,r){var i=e.getRangeBoundaryPosition(t,!0),o=e.getRangeBoundaryPosition(t,!1),a=r?o:i,s=r?i:o;return B(a,!!r,s,n)}function L(e,t,n){for(var r,i=[],o=k(e,t,n);r=o.next();)i.push(r);return o.dispose(),i}function A(t,n,r){var i=e.createRange(t.node);return i.setStartAndEnd(t.node,t.offset,n.node,n.offset),!i.expand("word",{wordOptions:r})}function I(e,t,n,r,i){function o(e,t){var n=g[e].previousVisible(),r=g[t-1],o=!i.wholeWordsOnly||A(n,r,i.wordOptions);return{startPos:n,endPos:r,valid:o}}for(var a,s,c,u,d,l,h=X(i.direction),p=B(e,h,e.session.getRangeBoundaryPosition(r,h),i.characterOptions),f="",g=[],v=null;a=p.next();)if(s=a.character,n||i.caseSensitive||(s=s.toLowerCase()),h?(g.unshift(a),f=s+f):(g.push(a),f+=s),n){if(d=t.exec(f))if(c=d.index,u=c+d[0].length,l){if(!h&&u<f.length||h&&c>0){v=o(c,u);break}}else l=!0}else if(-1!=(c=f.indexOf(t))){v=o(c,c+t.length);break}return l&&(v=o(c,u)),p.dispose(),v}function W(e){return function(){var t=!!wt,n=w(),r=[n].concat(j.toArray(arguments)),i=e.apply(this,r);return t||R(),i}}function _(e,t){return W(function(n,r,i,a){typeof i==V&&(i=r,r=$),a=o(a,ct);var s=e;t&&(s=i>=0,this.collapse(!s));var c=O(n.getRangeBoundaryPosition(this,s),r,i,a.characterOptions,a.wordOptions),u=c.position;return this[s?"setStart":"setEnd"](u.node,u.offset),c.unitsMoved})}function D(e){return W(function(t,n){n=G(n,it);for(var r,i=k(t,this,n,!e),o=0;(r=i.next())&&Y.test(r.character);)++o;i.dispose();var a=o>0;return a&&this[e?"moveStart":"moveEnd"]("character",e?o:-o,{characterOptions:n}),a})}function F(e){return W(function(t,n){var r=!1;return this.changeEachRange(function(t){r=t[e](n)||r}),r})}var V="undefined",$="character",M="word",q=e.dom,j=e.util,U=j.extend,G=j.createOptions,H=q.getBody,z=/^[ \t\f\r\n]+$/,K=/^[ \t\f\r]+$/,Y=/^[\t-\r \u0085\u00A0\u1680\u180E\u2000-\u200B\u2028\u2029\u202F\u205F\u3000]+$/,J=/^[\t \u00A0\u1680\u180E\u2000-\u200B\u202F\u205F\u3000]+$/,Q="en",X=e.Selection.isDirectionBackward,Z=!1,et=!1,tt=!1,nt=!0;!function(){var t=document.createElement("div");t.contentEditable="true",t.innerHTML="<p>1 </p><p></p>";var n=H(document),r=t.firstChild,i=e.getSelection();n.appendChild(t),i.collapse(r.lastChild,2),i.setStart(r.firstChild,0),Z=1==(""+i).length,t.innerHTML="1 <br>",i.collapse(t,2),i.setStart(t.firstChild,0),et=1==(""+i).length,t.innerHTML="1 <p>1</p>",i.collapse(t,2),i.setStart(t.firstChild,0),tt=1==(""+i).length,n.removeChild(t),i.removeAllRanges()}();var rt,it={includeBlockContentTrailingSpace:!0,includeSpaceBeforeBr:!0,includeSpaceBeforeBlock:!0,includePreLineTrailingSpace:!0,ignoreCharacters:""},ot={includeBlockContentTrailingSpace:!nt,includeSpaceBeforeBr:!et,includeSpaceBeforeBlock:!tt,includePreLineTrailingSpace:!0},at={en:{wordRegex:/[a-z0-9]+('[a-z0-9]+)*/gi,includeTrailingSpace:!1,tokenizer:n}},st={caseSensitive:!1,withinRange:null,wholeWordsOnly:!1,wrap:!1,direction:"forward",wordOptions:null,characterOptions:null},ct={wordOptions:null,characterOptions:null},ut={wordOptions:null,characterOptions:null,trim:!1,trimStart:!0,trimEnd:!0},dt={wordOptions:null,characterOptions:null,direction:"forward"},lt=q.getComputedStyleProperty;!function(){var e=document.createElement("table"),t=H(document);t.appendChild(e),rt="block"==lt(e,"display"),t.removeChild(e)}(),e.features.tableCssDisplayBlock=rt;var ht={table:"table",caption:"table-caption",colgroup:"table-column-group",col:"table-column",thead:"table-header-group",tbody:"table-row-group",tfoot:"table-footer-group",tr:"table-row",td:"table-cell",th:"table-cell"};N.prototype={get:function(e){return this.store.hasOwnProperty(e)?this.store[e]:null},set:function(e,t){return this.store[e]=t}};var pt=0,ft=0,gt={getPosition:function(e){var t=this.positions;return t.get(e)||t.set(e,new T(this,e))},toString:function(){return"[NodeWrapper("+q.inspectNode(this.node)+")]"}};x.prototype=gt;var vt="EMPTY",Ct="NON_SPACE",St="UNCOLLAPSIBLE_SPACE",yt="COLLAPSIBLE_SPACE",Nt="TRAILING_SPACE_BEFORE_BLOCK",mt="TRAILING_SPACE_IN_BLOCK",xt="TRAILING_SPACE_BEFORE_BR",Tt="PRE_LINE_TRAILING_SPACE_BEFORE_LINE_BREAK",bt="TRAILING_LINE_BREAK_AFTER_BR";U(gt,{isCharacterDataNode:m("isCharacterDataNode",q.isCharacterDataNode,"node"),getNodeIndex:m("nodeIndex",q.getNodeIndex,"node"),getLength:m("nodeLength",q.getNodeLength,"node"),containsPositions:m("containsPositions",d,"node"),isWhitespace:m("isWhitespace",v,"node"),isCollapsedWhitespace:m("isCollapsedWhitespace",C,"node"),getComputedDisplay:m("computedDisplay",a,"node"),isCollapsed:m("collapsed",S,"node"),isIgnored:m("ignored",y,"node"),next:m("nextPos",f,"node"),previous:m("previous",g,"node"),getTextNodeInfo:m("textNodeInfo",function(e){var t=null,n=!1,r=lt(e.parentNode,"whiteSpace"),i="pre-line"==r;return i?(t=K,n=!0):("normal"==r||"nowrap"==r)&&(t=z,n=!0),{node:e,text:e.data,spaceRegex:t,collapseSpaces:n,preLine:i}},"node"),hasInnerText:m("hasInnerText",function(e,t){for(var n=this.session,r=n.getPosition(e.parentNode,this.getNodeIndex()+1),i=n.getPosition(e,0),o=t?r:i,a=t?i:r;o!==a;){if(o.prepopulateChar(),o.isDefinitelyNonEmpty())return!0;o=t?o.previousVisible():o.nextVisible()}return!1},"node"),isRenderedBlock:m("isRenderedBlock",function(e){for(var t=e.getElementsByTagName("br"),n=0,r=t.length;r>n;++n)if(!S(t[n]))return!0;return this.hasInnerText()},"node"),getTrailingSpace:m("trailingSpace",function(e){if("br"==e.tagName.toLowerCase())return"";switch(this.getComputedDisplay()){case"inline":for(var t=e.lastChild;t;){if(!y(t))return 1==t.nodeType?this.session.getNodeWrapper(t).getTrailingSpace():"";t=t.previousSibling}break;case"inline-block":case"inline-table":case"none":case"table-column":case"table-column-group":break;case"table-cell":return"	";default:return this.isRenderedBlock(!0)?"\n":""}return""},"node"),getLeadingSpace:m("leadingSpace",function(){switch(this.getComputedDisplay()){case"inline":case"inline-block":case"inline-table":case"none":case"table-column":case"table-column-group":case"table-cell":break;default:return this.isRenderedBlock(!1)?"\n":""}return""},"node")});var Pt={character:"",characterType:vt,isBr:!1,prepopulateChar:function(){var e=this;if(!e.prepopulatedChar){var t=e.node,n=e.offset,r="",i=vt,o=!1;if(n>0)if(3==t.nodeType){var a=t.data,s=a.charAt(n-1),c=e.nodeWrapper.getTextNodeInfo(),u=c.spaceRegex;c.collapseSpaces?u.test(s)?n>1&&u.test(a.charAt(n-2))||(c.preLine&&"\n"===a.charAt(n)?(r=" ",i=Tt):(r=" ",i=yt)):(r=s,i=Ct,o=!0):(r=s,i=St,o=!0)}else{var d=t.childNodes[n-1];if(d&&1==d.nodeType&&!S(d)&&("br"==d.tagName.toLowerCase()?(r="\n",e.isBr=!0,i=yt,o=!1):e.checkForTrailingSpace=!0),!r){var l=t.childNodes[n];l&&1==l.nodeType&&!S(l)&&(e.checkForLeadingSpace=!0)}}e.prepopulatedChar=!0,e.character=r,e.characterType=i,e.isCharInvariant=o}},isDefinitelyNonEmpty:function(){var e=this.characterType;return e==Ct||e==St},resolveLeadingAndTrailingSpaces:function(){if(this.prepopulatedChar||this.prepopulateChar(),this.checkForTrailingSpace){var e=this.session.getNodeWrapper(this.node.childNodes[this.offset-1]).getTrailingSpace();e&&(this.isTrailingSpace=!0,this.character=e,this.characterType=yt),this.checkForTrailingSpace=!1}if(this.checkForLeadingSpace){var t=this.session.getNodeWrapper(this.node.childNodes[this.offset]).getLeadingSpace();t&&(this.isLeadingSpace=!0,this.character=t,this.characterType=yt),this.checkForLeadingSpace=!1}},getPrecedingUncollapsedPosition:function(e){for(var t,n=this;n=n.previousVisible();)if(t=n.getCharacter(e),""!==t)return n;return null},getCharacter:function(e){function t(){return p||(d=f.getPrecedingUncollapsedPosition(e),p=!0),d}this.resolveLeadingAndTrailingSpaces();var n,i=this.character,o=r(e.ignoreCharacters),a=""!==i&&o.indexOf(i)>-1;if(this.isCharInvariant)return n=a?"":i;var s=["character",e.includeSpaceBeforeBr,e.includeBlockContentTrailingSpace,e.includePreLineTrailingSpace,o].join("_"),c=this.cache.get(s);if(null!==c)return c;var u,d,l="",h=this.characterType==yt,p=!1,f=this;return h?(" "!=i||t()&&!d.isTrailingSpace&&"\n"!=d.character)&&("\n"==i&&this.isLeadingSpace?t()&&"\n"!=d.character&&(l="\n"):(u=this.nextUncollapsed(),u&&(u.isBr?this.type=xt:u.isTrailingSpace&&"\n"==u.character?this.type=mt:u.isLeadingSpace&&"\n"==u.character&&(this.type=Nt),"\n"==u.character?(this.type!=xt||e.includeSpaceBeforeBr)&&(this.type!=Nt||e.includeSpaceBeforeBlock)&&(this.type==mt&&u.isTrailingSpace&&!e.includeBlockContentTrailingSpace||(this.type!=Tt||u.type!=Ct||e.includePreLineTrailingSpace)&&("\n"==i?u.isTrailingSpace?this.isTrailingSpace||this.isBr&&(u.type=bt,t()&&d.isLeadingSpace&&"\n"==d.character&&(u.character="")):l="\n":" "==i&&(l=" "))):l=i))):"\n"==i&&(!(u=this.nextUncollapsed())||u.isTrailingSpace),o.indexOf(l)>-1&&(l=""),this.cache.set(s,l),l},equals:function(e){return!!e&&this.node===e.node&&this.offset===e.offset},inspect:b,toString:function(){return this.character}};T.prototype=Pt,U(Pt,{next:m("nextPos",function(e){var t=e.nodeWrapper,n=e.node,r=e.offset,i=t.session;if(!n)return null;var o,a,s;return r==t.getLength()?(o=n.parentNode,a=o?t.getNodeIndex()+1:0):t.isCharacterDataNode()?(o=n,a=r+1):(s=n.childNodes[r],i.getNodeWrapper(s).containsPositions()?(o=s,a=0):(o=n,a=r+1)),o?i.getPosition(o,a):null}),previous:m("previous",function(e){var t,n,r,i=e.nodeWrapper,o=e.node,a=e.offset,s=i.session;return 0==a?(t=o.parentNode,n=t?i.getNodeIndex():0):i.isCharacterDataNode()?(t=o,n=a-1):(r=o.childNodes[a-1],s.getNodeWrapper(r).containsPositions()?(t=r,n=q.getNodeLength(r)):(t=o,n=a-1)),t?s.getPosition(t,n):null}),nextVisible:m("nextVisible",function(e){var t=e.next();if(!t)return null;var n=t.nodeWrapper,r=t.node,i=t;return n.isCollapsed()&&(i=n.session.getPosition(r.parentNode,n.getNodeIndex()+1)),i}),nextUncollapsed:m("nextUncollapsed",function(e){for(var t=e;t=t.nextVisible();)if(t.resolveLeadingAndTrailingSpaces(),""!==t.character)return t;return null}),previousVisible:m("previousVisible",function(e){var t=e.previous();if(!t)return null;var n=t.nodeWrapper,r=t.node,i=t;return n.isCollapsed()&&(i=n.session.getPosition(r.parentNode,n.getNodeIndex())),i})});var wt=null,Rt=function(){function e(e){var t=new N;return{get:function(n){var r=t.get(n[e]);if(r)for(var i,o=0;i=r[o++];)if(i.node===n)return i;return null},set:function(n){var r=n.node[e],i=t.get(r)||t.set(r,[]);i.push(n)}}}function t(){this.initCaches()}var n=j.isHostProperty(document.documentElement,"uniqueID");return t.prototype={initCaches:function(){this.elementCache=n?function(){var e=new N;return{get:function(t){return e.get(t.uniqueID)},set:function(t){e.set(t.node.uniqueID,t)}}}():e("tagName"),this.textNodeCache=e("data"),this.otherNodeCache=e("nodeName")},getNodeWrapper:function(e){var t;switch(e.nodeType){case 1:t=this.elementCache;break;case 3:t=this.textNodeCache;break;default:t=this.otherNodeCache}var n=t.get(e);return n||(n=new x(e,this),t.set(n)),n},getPosition:function(e,t){return this.getNodeWrapper(e).getPosition(t)},getRangeBoundaryPosition:function(e,t){var n=t?"start":"end";return this.getPosition(e[n+"Container"],e[n+"Offset"])},detach:function(){this.elementCache=this.textNodeCache=this.otherNodeCache=null}},t}();U(q,{nextNode:f,previousNode:g});var Bt=Array.prototype.indexOf?function(e,t){return e.indexOf(t)}:function(e,t){for(var n=0,r=e.length;r>n;++n)if(e[n]===t)return n;return-1};U(e.rangePrototype,{moveStart:_(!0,!1),moveEnd:_(!1,!1),move:_(!0,!0),trimStart:D(!0),trimEnd:D(!1),trim:W(function(e,t){var n=this.trimStart(t),r=this.trimEnd(t);return n||r}),expand:W(function(e,t,n){var r=!1;n=o(n,ut);var i=n.characterOptions;if(t||(t=$),t==M){var a,s,c=n.wordOptions,u=e.getRangeBoundaryPosition(this,!0),d=e.getRangeBoundaryPosition(this,!1),l=E(u,i,c),h=l.nextEndToken(),p=h.chars[0].previousVisible();if(this.collapsed)a=h;else{var f=E(d,i,c);a=f.previousStartToken()}return s=a.chars[a.chars.length-1],p.equals(u)||(this.setStart(p.node,p.offset),r=!0),s&&!s.equals(d)&&(this.setEnd(s.node,s.offset),r=!0),n.trim&&(n.trimStart&&(r=this.trimStart(i)||r),n.trimEnd&&(r=this.trimEnd(i)||r)),r}return this.moveEnd($,1,n)}),text:W(function(e,t){return this.collapsed?"":L(e,this,G(t,it)).join("")}),selectCharacters:W(function(e,t,n,r,i){var o={characterOptions:i};t||(t=H(this.getDocument())),this.selectNodeContents(t),this.collapse(!0),this.moveStart("character",n,o),this.collapse(!0),this.moveEnd("character",r-n,o)}),toCharacterRange:W(function(e,t,n){t||(t=H(this.getDocument()));var r,i,o=t.parentNode,a=q.getNodeIndex(t),s=-1==q.comparePoints(this.startContainer,this.endContainer,o,a),c=this.cloneRange();return s?(c.setStartAndEnd(this.startContainer,this.startOffset,o,a),r=-c.text(n).length):(c.setStartAndEnd(o,a,this.startContainer,this.startOffset),r=c.text(n).length),i=r+this.text(n).length,{start:r,end:i}}),findText:W(function(t,n,r){r=o(r,st),r.wholeWordsOnly&&(r.wordOptions.includeTrailingSpace=!1);var i=X(r.direction),a=r.withinRange;a||(a=e.createRange(),a.selectNodeContents(this.getDocument()));var s=n,c=!1;"string"==typeof s?r.caseSensitive||(s=s.toLowerCase()):c=!0;var u=t.getRangeBoundaryPosition(this,!i),d=a.comparePoint(u.node,u.offset);-1===d?u=t.getRangeBoundaryPosition(a,!0):1===d&&(u=t.getRangeBoundaryPosition(a,!1));for(var l,h=u,p=!1;;)if(l=I(h,s,c,a,r)){if(l.valid)return this.setStartAndEnd(l.startPos.node,l.startPos.offset,l.endPos.node,l.endPos.offset),!0;h=i?l.startPos:l.endPos}else{if(!r.wrap||p)return!1;a=a.cloneRange(),h=t.getRangeBoundaryPosition(a,!i),a.setBoundary(u.node,u.offset,i),p=!0}}),pasteHtml:function(e){if(this.deleteContents(),e){var t=this.createContextualFragment(e),n=t.lastChild;this.insertNode(t),this.collapseAfter(n)}}}),U(e.selectionPrototype,{expand:W(function(e,t,n){this.changeEachRange(function(e){e.expand(t,n)})}),move:W(function(e,t,n,r){var i=0;if(this.focusNode){this.collapse(this.focusNode,this.focusOffset);var o=this.getRangeAt(0);r||(r={}),r.characterOptions=G(r.characterOptions,ot),i=o.move(t,n,r),this.setSingleRange(o)}return i}),trimStart:F("trimStart"),trimEnd:F("trimEnd"),trim:F("trim"),selectCharacters:W(function(t,n,r,i,o,a){var s=e.createRange(n);s.selectCharacters(n,r,i,a),this.setSingleRange(s,o)}),saveCharacterRanges:W(function(e,t,n){for(var r=this.getAllRanges(),i=r.length,o=[],a=1==i&&this.isBackward(),s=0,c=r.length;c>s;++s)o[s]={characterRange:r[s].toCharacterRange(t,n),backward:a,characterOptions:n};return o}),restoreCharacterRanges:W(function(t,n,r){this.removeAllRanges();for(var i,o,a,s=0,c=r.length;c>s;++s)o=r[s],a=o.characterRange,i=e.createRange(n),i.selectCharacters(n,a.start,a.end,o.characterOptions),this.addRange(i,o.backward)}),text:W(function(e,t){for(var n=[],r=0,i=this.rangeCount;i>r;++r)n[r]=this.getRangeAt(r).text(t);return n.join("")})}),e.innerText=function(t,n){var r=e.createRange(t);r.selectNodeContents(t);var i=r.text(n);return i},e.createWordIterator=function(e,t,n){var r=w();n=o(n,dt);var i=r.getPosition(e,t),a=E(i,n.characterOptions,n.wordOptions),s=X(n.direction);return{next:function(){return s?a.previousStartToken():a.nextEndToken()},dispose:function(){a.dispose(),this.next=function(){}}}},e.noMutation=function(e){var t=w();e(t),R()},e.noMutation.createEntryPointFunction=W,e.textRange={isBlockNode:u,isCollapsedWhitespaceNode:C,createPosition:W(function(e,t,n){return e.getPosition(t,n)})}}),e},this);