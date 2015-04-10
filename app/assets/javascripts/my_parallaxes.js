//Paralaxes
function myParalaxes()
{
	var prlxBlks = new Array(), i=0;
	getBlocks();
	goParallaxAction();
	
	function goParallaxAction() //обновляем блоки...
	{
		var v = '';
		for(var i=0; i<prlxBlks.length; i++)
		{
			prlxBlks[i].calBgPosition();
			v += "sp: "+prlxBlks[i].startPosition+"; bgTop: " + prlxBlks[i].background.css('top') + "; speed: "+(prlxBlks[i].speed)+"; sPoint"+prlxBlks[i].startPoint+"; ePoint"+prlxBlks[i].endPoint+"; Содержит подложку?: "+prlxBlks[i].containsWrapper+"; Отступ: "+prlxBlks[i].topOffset+"; Высота блока: "+prlxBlks[i].blHeight+"; Высота подложки: "+prlxBlks[i].bgHeight+"; Коэффициент: "+prlxBlks[i].heightCoeff +";<br />";
		}
		//$("#test").html(v);
	}
	$(window).scroll(function(){goParallaxAction();});
	$(window).resize(function(){goParallaxAction();});
	function getBlocks() //создаем массив из блоков и инициализируем их.
	{	
		$('div.pBox').each(
							function(i) {
											var pBl = new parallaxBlock(this.id);
											pBl.initPrlxBlock();
											prlxBlks[i] = pBl;
											i++;
										}
						  );
	}
}

function parallaxBlock(blID)
{
	this.blockID = blID; 			//id блока
	this.block = undefined;			//блок
	this.topOffset = 0;				//отступ блока от верхней границы документа
	this.background = undefined;	//подложка
	this.containsWrapper = false;	//есть ли подложка
	this.content = undefined;    	//блок контента
	this.cTopOffset = 0;			//Отступ контента от верхней границы документа
	this.blHeight = 0;				//высота блока
	this.bgHeight = 0; 				//высота подложки
	this.heightCoeff = 0.0; 		//коэффициент изменения 
	this.startPoint = 0; 			//начальная точка движения подложки
	this.endPoint = 0; 				//конечная точка движения подложки
	this.speed = 1.0;				//скорость движения подложки
	this.baseBgOffset = 0.0; 		//стартовые отступ
	this.curScrlTop = 0;			//текущее положение вертикального скроллера
	//methods
	this.initPrlxBlock = function() {
										this.block = $('#'+blID);
										this.background = this.block.find('.pB-wrapper');
										this.content = this.block.find('.pB-content');
										if (this.content.offset() !== undefined)
										{
											this.cTopOffset = this.content.offset().top;
											
										}else{this.content = undefined;}
										this.blHeight = this.block.height();
										this.bgHeight = this.background.height();
										if (this.blHeight < this.bgHeight)
										{
											if (this.background.attr('pb-speed') !== undefined)
											{
												this.speed = parseFloat(this.background.attr('pb-speed')); //скорость
											}
											if (this.background.attr('pb-start-position') != undefined)
											{
												this.startPosition = this.background.attr('pb-start-position');
												if (this.startPosition == 'out'){this.baseBgOffset = (this.bgHeight*this.speed)/2}
											}
											
											
											this.containsWrapper = true;
											this.getHeightCoeff();
										}
										
									};
	this.getHeightCoeff = function() {
										this.getKeyPoints();
										this.heightCoeff = (parseFloat(this.bgHeight-this.blHeight+this.baseBgOffset))/parseFloat(this.endPoint-this.startPoint);
									 };
									 
	this.calBgPosition = function() {
										var span, bgTop;
										this.curScrlTop = $(window).scrollTop();
										
										if (this.curScrlTop>=this.startPoint && this.curScrlTop<this.endPoint && this.containsWrapper == true)
										{
											span = this.startPoint - this.curScrlTop;
											bgTop = parseFloat(span)*this.heightCoeff*this.speed+this.baseBgOffset;	
											if (bgTop > this.bgHeight)
											{
												bgTop = this.bgHeight+this.baseBgOffset;
											}else if (bgTop > this.baseBgOffset )
												{
													bgTop = this.baseBgOffset;	
												}
											if (this.background.hasClass('pB-top-to-bot'))
											{
												this.background.css('top', bgTop + 'px');
											}else {
													this.background.css('bottom', bgTop + 'px');
												  }
											
										}
									}
	this.getKeyPoints = function() {
											var wHeight, docHeight, blBotOffset,startOffsets;
											this.topOffset = this.block.offset().top;
											wHeight = $(window).height();
											startOffsets = parseFloat(wHeight)*0.2;
											docHeight = $(document).height();
											blBotScrlTop = this.blHeight + this.topOffset;
										
											if (this.topOffset<wHeight)
											{
												this.startPoint = 0;
											}else{
													this.startPoint=this.topOffset-wHeight;
												 }
											if ((docHeight-wHeight)<blBotScrlTop)
											{
												this.endPoint = docHeight-wHeight;
											} else {this.endPoint=blBotScrlTop-startOffsets;}
								   }
	this.contentMakeEffects = function() {
											
											var wHeight, sPoint, ePoint;
											wHeight = $(window).height();
											
											if (this.contEffects !== 'none')
											{
												if (this.contEffects == 'fadeOnPlace')
												{
													this.cFadeOnPlace();//изменение прозрачности без изменения положения
												} 
												else if (this.contEffects == 'fadeOnRigthToLeft')
												{
													//изменение видимости с задержкой по середине
												}
												//добавлять эффекты сюда.
											}
										 }
	this.cFadeOnPlace = function() {
										
										
										
								   }
}
//Paralaxes end