/**
 * Copyright (C) 2021, 5DPLAY Game Studio
 * All rights reserved.
 * 
 * This software is distributed under the MIT license.
 * Any person or organization may use this library free of charge, 
 * but it must follow the following points :
 * 
 * 1. No person or organization may claim to 
 *    have written the original source code.
 * 
 * 2. In any case, the author is not liable for 
 *    any consequences caused by the use of part 
 *    of the code of this software.
 * 
 * 3. This section shall not be deleted or altered 
 *    from any source.
 * 
 */

/**
 * 改自莎莎的FnLIB，主要还是根据个人习惯加了很多稀奇古怪 但非常实用的东西
 * 目前处于测试版 希望各位会喜欢
 * 
 * ---------- tips: ---------
 * 使用方法::
 * 确保 SFALIB.as 文件放在 fla 文件同级目录下，
 * 在 人物/辅助/独立道具/飞行道具 第一帧，
 * 加入 include "SFALIB.as" 语句，
 * 即可在源文件中使用本文件提供的快捷访问属性。
 */

//////////////////////////////////////////////////////////////////////////////////////////

//                                   我是可爱的分割线

//////////////////////////////////////////////////////////////////////////////////////////

// 导入 flash 包 
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.FrameLabel;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;
import flash.utils.Dictionary;
import flash.events.Event;
import flash.media.SoundTransform;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.geom.ColorTransform;
import flash.display.Bitmap;
import flash.filters.BlurFilter;
import flash.geom.Point;
import flash.geom.Rectangle;

// SFALIB 相关变量

// 相关信息
const IS_PRINT:Boolean = false;

const VERSION:String = "0.1.1";			// 版本
const AUTHOR :String = "5dplay";		// 作者
const EDIT   :String = "LittleFatasmaGod";		// 二次编辑
const DATE   :String = "2025/5/13";	// 日期

// 获取所需全部包名引用
const BVN_PATH:String = "net.play5d.game.bvn.";
const KYO_PATH:String = "net.play5d.kyo.";

const PKG_NAME_FIGHTER:String = BVN_PATH + "fighter::"
const PKG_NAME_CTRL_GAMECTRLS:String = BVN_PATH + "ctrl.game_ctrls::"

// 获取类引用

var FighterMain:Class = getDefinitionByName(PKG_NAME_FIGHTER + _TYPE_FIGHTER_MAIN);
var Assister:Class = getDefinitionByName(PKG_NAME_FIGHTER + _TYPE_ASSISTER);
var Bullet:Class = getDefinitionByName(PKG_NAME_FIGHTER + _TYPE_BULLET);
var FighterAttacker:Class = getDefinitionByName(PKG_NAME_FIGHTER + _TYPE_FIGHTER_ATTACKER);

var GameCtrl:Class = getDefinitionByName(PKG_NAME_CTRL_GAMECTRLS + "GameCtrl");

// 自身引用 (私有变量 不建议引用)
var _this:MovieClip = this as MovieClip;

const _TYPE_FIGHTER_MAIN    :String = "FighterMain";
const _TYPE_ASSISTER        :String = "Assister";
const _TYPE_BULLET          :String = "Bullet";
const _TYPE_FIGHTER_ATTACKER:String = "FighterAttacker";
const _TYPE_UNKNOWN         :String = "Unknown";

const _NOT_APPLICABLE:String = "[N/A]";

var _selfType:String = null;

var _displayIsStage:* = null;


/**
 * 初始化 SFALIB	
 */
function initlizeSFALIB():void {

   // 添加初始化事件监听器，监听被添加到场景的场景	
	this.addEventListener(Event.ADDED_TO_STAGE, initStage);
	_print();
}

/**
 * 初始化场景
 */
function initStage(e:Event):void {

	// 初始化物理帧渲染器
	$self.delayCall(this.render, 1);

	// 初始化动画帧渲染器
	$self.setAnimateFrameOut(this.renderAnimate, 1);
}

/**
 * 打印自身信息
 */
function _print():void {
	if (!IS_PRINT) {
		return;
	}
	
	var text:String = 
		"[SFALIB]::{\n\t" + 
			"Ver:" + VERSION + ", Author:" + AUTHOR +", Edit:" + EDIT + ", Date:" + DATE + "\n\t" + 
			"SelfType:" + _getSelfType() + ", Name:" + $name + "\n" + 
		"}"
	;
	
	trace(text);
}

//////////////////////////////////////////////////////////////////////////////////////////

//                                 工具相关方法

//////////////////////////////////////////////////////////////////////////////////////////

/**
 * 检测一个类是否存在。
 * @param className 类的完全限定名（包括包名）。
 * @return 返回类是否存在的布尔值 (Boolean 类型)
 */
function classExists(className:String):Boolean {
    if (!className) {
        return false;
    }
    try {
        getDefinitionByName(className);
        return true;
    } catch (error:ReferenceError) {
        return false;
    }
}

/**
 * 获取类
 * @param className 类名名称 (String类型 默认:null)
 * @param classType 类包类型 (String 类型 默认:"bvn") 
 * @return 返回类包 (Class 类型)
 */

function getClass(className: String = null, classType: String = "bvn"):Class {
	var path: String;

	if (!className) {
		throw new Error("getClass:未定义类名称");
		return null;
	}
	switch (classType) {
		case "bvn":
		  path = BVN_PATH;
		break;
		case "kyo":
		  path = KYO_PATH;
		break;
		default:
		  path = "";
		break;
	}
	if (classExists(path + className)) 
	    return getDefinitionByName(path + className ) as Class;
	else {
		trace("SFALIB.getClass::" + "(" + className + ")" + "类不存在");
		return null;	
	}	
}


/**
 * 获取自身类型
 * @return 返回自身类型
 */
function _getSelfType():String {
	if (_selfType) {
		return _selfType;
	}
	
	_selfType = _getType($self);
	
	return _selfType;
}

/**
 * 获取类型
 * 
 * @param sp 指定sp
 * @return 返回类型
 */
function _getType(sp:*):String {
	const TYPE_ARRAY:Array = [{
			cls :  FighterMain, 
			type: _TYPE_FIGHTER_MAIN
		}, {
			cls :  Assister, 
			type: _TYPE_ASSISTER
		}, {
			cls :  Bullet, 
			type: _TYPE_BULLET
		}, {
			cls :  FighterAttacker, 
			type: _TYPE_FIGHTER_ATTACKER
		}
	];
	
	var type:String = _TYPE_UNKNOWN;
	
	// 遍历是否存在当前的类型
	for each (var o:Object in TYPE_ARRAY) {
		var cls :Class  = o.cls as Class;
		
		if (sp is cls) {
			type = o.type as String;
			
			break;
		}
	}
	
	return type;
}

//////////////////////////////////////////////////////////////////////////////////////////

//                                 控制器相关方法

//////////////////////////////////////////////////////////////////////////////////////////

var _self:* = null;

/**
 * 获得自身类引用
 * *@return 返回自身 Class
 */
function get $self():* {
	if (_self) {
		return _self;
	}
	
	try {
		var gameStage  :* = GameCtrl.I.gameState;
		var gameSprites:* = gameStage.getGameSprites();
		
		for each (var sp:* in gameSprites) {
			var d:DisplayObject = sp.getDisplay();
			
			// 等于 this 可获取 FighterAttacker Bullet Assister
			// 等于 this.parent 可获取 FighterMain
			if (d == _this || d == _this.parent) {
				_self = sp;
				
				return _self;
			}
		}
	}
	catch (e:Error) {}
	
	return null;
}

var _owner:* = null;

/**
 * 获得最顶主人类引用，始终返回 FighterMain
 * @return 返回玩家 FighterMain
 */
function get $owner():* {
	if (_owner) {
		return _owner;
	}
	
	var tOwner:* = null;
	
	/**
	 * FighterMain 直接返回
	 * Assister 的 owner 只可能是 FighterMain
	 * Bullet 的 owner 可能是 FighterMain Assister FighterAttacker
	 * FighterAttacker 的 owner 可能是 FighterMain Assister
	 */
	
	try {
		switch (_getSelfType()) {
		case _TYPE_FIGHTER_MAIN:
			_owner = $self;
			
			break;
		case _TYPE_ASSISTER:
			_owner = $self.getOwner();
			
			break;
		case _TYPE_BULLET:
			tOwner = $self.owner;
			
			switch (_getType(tOwner)) {
			case _TYPE_FIGHTER_MAIN:
				_owner = tOwner;
				
				break;
			case _TYPE_ASSISTER:
				_owner = tOwner.getOwner();
				
				break;
			case _TYPE_FIGHTER_ATTACKER:
				tOwner = tOwner.getOwner();
				
				switch (_getType(tOwner)) {
				case _TYPE_FIGHTER_MAIN:
					_owner = tOwner;
					
					break;
				case _TYPE_ASSISTER:
					_owner = tOwner.getOwner();
					
					break;
				}
				
				break;
			}
			
			break;
		case _TYPE_FIGHTER_ATTACKER:
			tOwner = $self.getOwner();
			
			switch (_getType(tOwner)) {
			case _TYPE_FIGHTER_MAIN:
				_owner = tOwner;
				
				break;
			case _TYPE_ASSISTER:
				_owner = tOwner.getOwner();
				
				break;
			}
			
			break;
		}
	}
	catch (e:Error) {
		return null;
	}
	
	return _owner;
}


/**
 * 获取自身角色主人 
 * @return 返回自身角色主人 (FighterMain 类型)
 */
function get $ownerFighter():* {
	if (_getSelfType() != _TYPE_BULLET) return $owner;

	if (_getType($owner) == _TYPE_FIGHTER_ATTACKER || _getType($owner) == _TYPE_ASSISTER)
	   return $owner.getOwner();
	
	return $owner;
}

/**
 * 获取BVN角色影片剪辑
 * @return BVN角色影片剪辑 (MovieClip 类型)
 */
function findBvnMovieClip(container:MovieClip):MovieClip {
	var numChildren:int = container.numChildren;

	for (var i: int = 0; i < numChildren; i++) {
		var child: DisplayObject = container.getChildAt(i);
		if (!child) continue;
		if (child is MovieClip) {
			var labels: Array = MovieClip(child).currentLabels.map(function (frame: FrameLabel, ...rest): String {
				return frame.name;
			});
			var frameLabels: Array = ["站立", "走", "被打", "开场"];
			var allLabelsPresent: Boolean = frameLabels.every(function (label: String, ...rest): Boolean {
				return labels.indexOf(label) != -1;
			});
			if (allLabelsPresent) return child as MovieClip;
		}
	}
	return null;
}

/**
 * 检测_this是否是舞台
 * @return 返回检测的布尔值 (Boolean 类型 注: 如果无法找到对应的目标 则:: 返回 null)
 */
function get checkIsStage():* {
	if (_getSelfType() != _TYPE_FIGHTER_MAIN) return null;

	if (_displayIsStage != null) return _displayIsStage;

	try {
		var gameStage  :* = GameCtrl.I.gameState;
		var gameSprites:* = gameStage.getGameSprites();
		
		for each (var sp:* in gameSprites) {
			var d:DisplayObject = sp.getDisplay();

			if (d == _this) {
				_displayIsStage = false;
			    return false;
			} else if (d == _this.parent) {
				_displayIsStage = true
			     return true;	
			  }	 
		}
	}
	catch (e:Error) {}
	
	return null;
}

/**
 * 获取当前主体的影片剪辑
 * @return 当前主体的影片剪辑 (MovieClip 类型)
 */
function get $mc():MovieClip {
	var display:MovieClip = null;

	if (_getSelfType() == _TYPE_FIGHTER_MAIN) {
	   display = (checkIsStage ? _this.parent : _this) as MovieClip;
	   	return findBvnMovieClip(display);
	} else display = _this as MovieClip;

	return display;

}

var _target:* = null;

/**
 * 获得对手主人类引用，始终返回 FighterMain
 * @return 返回对手 FighterMain
 */
function get $target():* {
	if (_target) {
		return _target;
	}
	
	try {
		_target = $owner.getCurrentTarget();
	}
	catch (e:Error) {
		return null;
	}
	
	return _target as FighterMain;
}

/**
 * 获取敌方主体的影片剪辑
 * @return 当前敌方的影片剪辑 (MovieClip 类型)
 */
function get $tmc():MovieClip {
	if (!$target) return null;

	var display:DisplayObject = null;

    try {
	    display = $target.getDisplay()	
	} catch (e:Error) {
		return null;
	}

	return findBvnMovieClip(display as MovieClip);
}

/**
 * 获取主人主体的影片剪辑
 * @return 当前主人主体的影片剪辑 (MovieClip 类型)
 */
function get $omc():MovieClip {
	if (!$owner) return null;

	var display:DisplayObject = null;

    try {
	    display = $owner.getDisplay()	
	} catch (e:Error) {
		return null;
	}

	return findBvnMovieClip(display as MovieClip);
}

/**
 * 获取角色主人的影片剪辑
 * @return 当前角色主人的影片剪辑 (MovieClip 类型)
 */
function get $omcFighter():MovieClip {
	if (!$ownerFighter) return null;
	 
	var display:DisplayObject = null;

    try {
	    display = $ownerFighter.getDisplay()	
	} catch (e:Error) {
		return null;
	}

	return findBvnMovieClip(display as MovieClip);
}



var _key:*;

/**
 * 获取我方按键控制器
 * @return 当前我方按键控制器 (FighterKey 类型)
 */
function get $key():* {
  
	// 类相关变量
	var FighterKey:Class = getClass("fighter.ctrler::FighterKeyCtrl") as Class;
	var GameData:* = getClass("data::GameData").I;
	var ConfigVO:* = GameData.config;
	var key:*;
	
   // 如果影片剪辑接口的获取动作接口函数存在 则: 返回
	if ($owner.getCtrler().getMcCtrl().getActionCtrler != null) {
		return $owner.getCtrler().getMcCtrl().getActionCtrler();
	}
	
   // 如果按键变量已存在 则: 返回按键变量
	if (_key) {
		return _key;
	}
	
   // 创建新的FighterKey并赋值于按键变量
	key = new FighterKey();
	key.inputType = $self.team.name;
	key.classicMode = ConfigVO.keyInputMode;
	_key = key;
	return key;
}

var _tkey:*;

/**
 * 获取敌方按键控制器
 * @return 当前敌方按键控制器 (FighterKey 类型)
 */
function get $tkey():* {
  
	// 类相关变量
	var FighterKey:Class = getClass("fighter.ctrler::FighterKeyCtrl") as Class;
	var GameData:* = getClass("data::GameData").I;
	var ConfigVO:* = GameData.config;
	var key:*;
	
   // 如果影片剪辑接口的获取动作接口函数存在 则: 返回
	if ($target.getCtrler().getMcCtrl().getActionCtrler != null) {
		return $target.getCtrler().getMcCtrl().getActionCtrler();
	}
	
   // 如果按键变量已存在 则: 返回按键变量
	if (_key) {
		return _key;
	}
	
   // 创建新的FighterKey并赋值于按键变量
	key = new FighterKey();
	key.inputType = isP1 ? "P2" : "P1";
	key.classicMode = ConfigVO.keyInputMode;
	_tkey = key;
	return _tkey;
}

/**
 * 获得自身名称
 * @return 返回自身名称
 */
function get $name():String {
	try {
		if ($self) {
			return $self.getDisplay().name;
		}
	}
	catch (e:Error) {}
	
	return _NOT_APPLICABLE;
}

/**
 * 调试工具类
 */
function get $debug():Class {
	if (classExists(BVN_PATH + "Debugger")) {
		return getClass("Debugger");
    } else if (classExists(BVN_PATH + "debug.Debugger"))
	    return getClass("debug.Debugger");
	
	return null;	
}

/**
* 获取控制器 (目前只支持3.3与真牛逼版)
* @param ctrlerName 接口名称(String 类型)
* @param ctrlerType 接口类型(Boolean 类型) 
* @return 返回输入所对应的控制器 (任意类型)
*/	
function getCtrl(ctrlerName:String, ctrlerType:Boolean = true):* {
	var result:* = null;
	var param:* = null;
	try {

   // 筛选自身类型		
	 switch (_getSelfType()) {
		case _TYPE_FIGHTER_MAIN: // 如果自身是角色
		 if (ctrlerType) {
			 switch (ctrlerName) {

			  // -------  当前目标  -------

				case "fighterCtrler":
				case "fc":
				 result = $self.getCtrler();
				break;
				case "mcCtrler":
				case "mc":
				 result = $self.getCtrler().getMcCtrl();
				break;
				case "effectCtrler":
				case "ec":
				 result = $self.getCtrler().getEffectCtrl();
				break;
				case "fighterMC":
				case "fmc":
				 result = $self.getCtrler().getMcCtrl().getFighterMC();
				break;
				case "fighterBuffCtrler":
				case "bc":
				 result = $self.getBuffCtrl();
				break;
				case "fighterAction":
				case "ac":
				 result = $self.getCtrler().getMcCtrl().getAction();
				break;
				case "fighterHitModel":
				case "fh":
				 result = $self.getCtrler().hitModel;
				break;
				case "fighterVoiceCtrler":
				case "vc":
				 result = $self.getCtrler().getVoiceCtrl(); 
				break;
				case "fighterVO":
				 result = $self.data;
				break; 
				case "assisterFighterVO":
				case "afv":
				 if (isP1) 
				     result = getClass("data.AssisterModel").I.getAssister( getClass("data.GameData").I.p1Select.fuzhu);
				else
				     result = getClass("data.AssisterModel").I.getAssister( getClass("data.GameData").I.p2Select.fuzhu);
				break;	  	 
				case "fighterActionState":
				case "fas":
				 result = getClass("fighter.FighterActionState");
				break;
				case "actionState":
				case "as":
				 result = $self.actionState;
				break;
				case "display":
				 result = $self.getDisplay();
				break;
				case "mc":
				 result = $mc;
				break;  
				case "main":
				 result = $self;
				break;  

			  // -------  敌方目标  -------

			  case "target_fighterCtrler":  
			  case "tfc":
			   result = $target.getCtrler();
			  break;
			  case "target_mcCtrler":
			  case "tmc":
			   result = $target.getCtrler().getMcCtrl();
			  break;
			  case "target_effectCtrler":
			  case "tec":
			   result = $target.getCtrler().getEffectCtrl();
			  break;
			  case "target_fighterMC":
			  case "tfmc":
			   result = $target.getCtrler().getMcCtrl().getFighterMC();
			  break;
			  case "target_fighterBuffCtrler":
			  case "tbc":
			   result = $target.getBuffCtrl();
			  break;
			  case "target_fighterAction":
			  case "tac":
			   result = $target.getCtrler().getMcCtrl().getAction();
			  break;
			  case "target_fighterHitModel":
			  case "tfh":
			   result = $target.getCtrler().hitModel;
			  break;
			  case "target_fighterVoiceCtrler":
			  case "tvc":
			   result = $target.getCtrler().getVoiceCtrl();
			  break;
			  case "target_fighterVO":
			   result = $target.data;
			  break;
			  case "target_assisterFighterVO":
				case "tafv":
				 if (isP1) 
				     result = getClass("data.AssisterModel").I.getAssister(getClass("data.GameData").I.p2Select.fuzhu);
				else
				     result = getClass("data.AssisterModel").I.getAssister(getClass("data.GameData").I.p1Select.fuzhu);
			 break; 
			  case "target_actionState":
			  case "tas":
			   result = $target.actionState;
			  break;
			  case "target_display":
			   result = $target.getDisplay();
			  break;
			  case "target_mc":
			   result = $tmc;
			  break; 
			  case "target_main":
			   result = $target;
			  break;  
			 }
		 } else {
			switch (ctrlerName) {

			   // -------  游戏控制器  -------

                case "mainGame":
				 result = getClass("MainGame").I;
				break; 
				case "gameCtrl":
				case "gc":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I;
				break;
				case "gameState":
				case "gs":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState;
				break;
				case "gameSprites":
				case "sprites":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState.getGameSprites();
				break; 
				case "gameLogic":
				case "logic":
				 result = getClass("ctrl.GameLogic");
				break;
				case "gameLoader":
				case "loader":
				 result = getClass("ctrl.GameLoader");
				break;
				case "gameLogger":
				case "log":
				 result = Log;
				break;
				case "gameEvent":
				case "event":
				 result	= getClass("ctrl.GameEvent");
				break;
				case "gameRender":
				case "render":
				 result = getClass("ctrl.GameRender");
				break;
				case "gameRunData":
				case "runData":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData;
				break;
				case "gameData":
				case "data":
				 result = getClass("data.GameData").I;
				break;
				case "gameMode":
				case "mode":
				 result = getClass("data.GameMode");
				case "gameInputer":
				case "input":
				 result = getClass("input.GameInputer");
				break;  
				break;  
				case "gameUI":
				case "ui":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState.gameUI;
				break;
				case "IGameUI":
				case "iui":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState.gameUI.getUI();
				break; 
				case "uiDisplay":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState.gameUI.getUIDisplay();
				break;

			   // -------  特效控制器  -------

			    case "effectCtrl":
				case "ec":
				 result = getClass("ctrl.EffectCtrl").I;
				break;
				case "effectModel":
				case "em":
				 result = getClass("data.EffectModel");
				break;
				case "effectManager":
				case "manager":
				 result = getClass("utils.EffectManager");
				break; 

			  // -------  角色组 -------

			   case "fighterGroup":
			   case "group":
			    result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p1FighterGroup.currentFighter.getDisplay() ==
				  $self.getDisplay() ?  getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p1FighterGroup :
				   getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p2FighterGroup;
				break;
				case "target_fighterGroup":
				case "tgroup":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p1FighterGroup.currentFighter.getDisplay() ==
				  $self.getDisplay() ?  getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p2FighterGroup :
				   getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p1FighterGroup;
				break;

			  //  -------  地图控制器  -------

			   case "mapMain":
			   case "map":
			    result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.map;
			   break;
			   case "mapVO":
			    getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.map.data;
			   break;
			   case "mapModel":
			    result = getClass("data.MapModel").I;
			   break;

			  //  -------  场景控制器  -------
			   
			   case "stageCtrl":
			    result = getClass("MainGame").stageCtrl;
			   break;
			   case "stage":
			    result = getClass("MainGame").stageCtrl.currentStage;

			 //  -------  资源管理器  -------

			  case "assetManager":
			  case "am":
			   result = getClass("ctrl.AssetManager").I;
			  break;

			//  -------  音效控制器  -------

			 case "soundCtrl":
			 case "sound":
			  result = getClass("ctrl.SoundCtrl").I;
			 break;

			//  -------  角色事件库  -------

			 case "fighterEvent":
			 case "fe":
			  result = getClass("fighter.events.FighterEvent");
			 break;
			 case "fighterEventDispatcher":
			 case "fed":
			  result = getClass("fighter.events.FighterEventDispatcher");
			 break; 

			//  -------  Kyo工具库  -------

			 case "kyoUtil":
			 case "util":
			  result = getClass("utils.KyoUtils", "kyo");
			 break;
			 case "kyoRandom":
			 case "random":
			  result = getClass("utils.KyoRandom", "kyo");
			 break;
			 case "kyoMath":
			 case "math":
			  result = getClass("utils.KyoMath", "kyo");      
			 break;  

		   //  -------  调试工具类  -------

		    case "debug":
			 result = $debug;
			break;

		  //  -------  精灵控制器  -------

		   case "fighterModel":
		   case "fm":
		    result = getClass("data.EffectModel").I;
		   break;
		   case "fighterKey":
		   case "key":
		    result = $key;
		   break;		 	
		   case "target_fighterKey":
		   case "tkey":
		    result = $tkey;
		   break;	
			}	
		   }			 	
		break;
		case _TYPE_ASSISTER: // 如果自身是辅助
		 if (ctrlerType) {
			 switch (ctrlerName) {

			   //  -------  当前目标  -------

                case "assister":
				case "ast":
				 result = $self;
			    case "assissterCtrler":
				case "astc":
				 result = $self.getCtrler();
				break;
				case "mc":
				 result = $mc;
				break;

			  //  -------  主人控制器  -------

			   case "owner_fighterCtrler":
				case "ofc":
				 result = $owner.getCtrler();
				break;
				case "owner_mcCtrler":
				case "omc":
				 result = $owner.getCtrler().getMcCtrl();
				break;
				case "owner_effectCtrler":
				case "oec":
				 result = $owner.getCtrler().getEffectCtrl();
				break;
				case "fighterMC":
				 result = $owner.getCtrler().getMcCtrl().getFighterMC();
				break;
				case "owner_fighterBuffCtrler":
				case "obc":
				 result = $owner.getBuffCtrl();
				break;
				case "owner_fighterAction":
				case "oac":
				 result = $owner.getCtrler().getMcCtrl().getAction();
				break;
				case "owner_fighterHitModel":
				case "ofh":
				 result = $owner.getCtrler().hitModel;
				break;
				case "owner_fighterVoiceCtrler":
				case "ovc":
				 result = $owner.getCtrler().getVoiceCtrl(); 
				break;
				case "owner_fighterVO":
				 result = $owner.data;
				break; 
				case "fighterActionState":
				case "fas":
				 result = getClass("fighter.FighterActionState");
				break;
				case "owner_actionState":
				case "oas":
				 result = $owner.actionState;
				break;
				case "owner_display":
				 result = $owner.getDisplay();
				break; 
				case "owner_mc":
				case "omc":
				 result = $omc;
				break;  
				case "owner_main":
				 result = $owner;
				break;

			  //  -------  敌方目标  -------

			   case "target_assister":
			   case "tast":
			    if (isP1)
				    result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p2FighterGroup.fuzhu;
				else
				   result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p1FighterGroup.fuzhu;
                break;
				case "target_assisterCtrler":
				case "tastc":
				 if (isP1)
				    result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p2FighterGroup.fuzhu.getCtrler();
				else
				   result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p1FighterGroup.fuzhu.getCtrler();
                break;

			   //  -------  主人控制器  -------

			    case "target_fighterCtrler":
				case "tfc":
				 result = $target.getCtrler();
				break;
				case "target_mcCtrler":
				case "tmc":
				 result = $target.getCtrler().getMcCtrl();
				break;
				case "target_effectCtrler":
				case "tec":
				 result = $target.getCtrler().getEffectCtrl();
				break;
				case "target_fighterMC":
				case "tfmc":
				 result = $target.getCtrler().getMcCtrl().getFighterMC();
				break;
				case "target_fighterBuffCtrler":
				case "tbc":
				 result = $target.getBuffCtrl();
				break;
				case "target_fighterAction":
				case "tac":
				 result = $target.getCtrler().getMcCtrl().getAction();
				break;
				case "target_fighterHitModel":
				case "tfh":
				 result = $target.getCtrler().hitModel;
				break;
				case "target_fighterVoiceCtrler":
				case "tvc":
				 result = $target.getCtrler().getVoiceCtrl(); 
				break;
				case "target_fighterVO":
				 result = $target.data;
				break; 
				case "target_fighterActionState":
				case "tfas":
				 result = getClass("fighter.FighterActionState");
				break;
				case "target_actionState":
				case "tas":
				 result = $target.actionState;
				break;
				case "target_display":
				 result = $target.getDisplay();
				break; 
				case "target_mc":
				case "tmc":
				 result = $tmc;
				break;  
				case "target_main":
				 result = $target;
				break;
			 }
		 } else {
			switch (ctrlerName) {

			   // -------  游戏控制器  -------

                case "mainGame":
				 result = getClass("MainGame").I;
				break; 
				case "gameCtrl":
				case "gc":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I;
				break;
				case "gameState":
				case "gs":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState;
				break;
				case "gameSprites":
				case "sprites":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState.getGameSprites();
				break; 
				case "gameLogic":
				case "logic":
				 result = getClass("ctrl.GameLogic");
				break;
				case "gameLoader":
				case "loader":
				 result = getClass("ctrl.GameLoader");
				break;
				case "gameLogger":
				case "log":
				 result = Log;
				break;
				case "gameEvent":
				case "event":
				 result	= getClass("ctrl.GameEvent");
				break;
				case "gameRender":
				case "render":
				 result = getClass("ctrl.GameRender");
				break;
				case "gameRunData":
				case "runData":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData;
				break;
				case "gameData":
				case "data":
				 result = getClass("data.GameData").I;
				break;
				case "gameMode":
				case "mode":
				 result = getClass("data.GameMode");
				case "gameInputer":
				case "input":
				 result = getClass("input.GameInputer");
				break;  
				break;  
				case "gameUI":
				case "ui":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState.gameUI;
				break;
				case "IGameUI":
				case "iui":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState.gameUI.getUI();
				break; 
				case "uiDisplay":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState.gameUI.getUIDisplay();
				break;

			   // -------  特效控制器  -------

			    case "effectCtrl":
				case "ec":
				 result = getClass("ctrl.EffectCtrl").I;
				break;
				case "effectModel":
				case "em":
				 result = getClass("data.EffectModel");
				break;
				case "effectManager":
				case "manager":
				 result = getClass("utils.EffectManager");
				break; 

			  // -------  角色组 -------

			   case "fighterGroup":
			   case "group":
			    result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p1FighterGroup.fuzhu.getDisplay() ==
				  $self.getDisplay() ?  getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p1FighterGroup :
				   getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p2FighterGroup;
				break;
				case "target_fighterGroup":
				case "tgroup":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p1FighterGroup.fuzhu.getDisplay() ==
				  $self.getDisplay() ?  getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p2FighterGroup :
				   getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p1FighterGroup;
				break;

			  //  -------  地图控制器  -------

			   case "mapMain":

			   case "map":
			    result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.map;
			   break;
			   case "mapVO":
			    getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.map.data;
			   break;
			   case "mapModel":
			    result = getClass("data.MapModel").I;
			   break;

			  //  -------  场景控制器  -------
			   
			   case "stageCtrl":
			    result = getClass("MainGame").stageCtrl;
			   break;
			   case "stage":
			    result = getClass("MainGame").stageCtrl.currentStage;

			 //  -------  资源管理器  -------

			  case "assetManager":
			  case "am":
			   result = getClass("ctrl.AssetManager").I;
			  break;

			//  -------  音效控制器  -------

			 case "soundCtrl":
			 case "sound":
			  result = getClass("ctrl.SoundCtrl").I;
			 break;

			//  -------  角色事件库  -------

			 case "fighterEvent":
			 case "fe":
			  result = getClass("fighter.events.FighterEvent");
			 break;
			 case "fighterEventDispatcher":
			 case "fed":
			  result = getClass("fighter.events.FighterEventDispatcher");
			 break;

			//  -------  Kyo工具库  -------

			 case "kyoUtil":
			 case "util":
			  result = getClass("utils.KyoUtils", "kyo");
			 break;
			 case "kyoRandom":
			 case "random":
			  result = getClass("utils.KyoRandom", "kyo");
			 break;
			 case "kyoMath":
			 case "math":
			  result = getClass("utils.KyoMath", "kyo");      
			 break;  

		   //  -------  调试工具类  -------

		    case "debug":
			 result = $debug;
			break;

		  //  -------  精灵控制器  -------

		   case "fighterModel":
		   case "fm":
		    result = getClass("data.EffectModel").I;
		   break;
		   case "fighterKey":
		   case "key":
		    result = $key;
		   break;		 	
		   case "target_fighterKey":
		   case "tkey":
		    result = $tkey;
		   break;	
			}	
		   }
		break;
		case _TYPE_FIGHTER_ATTACKER: // 如果自身是攻击对象
		  if (ctrlerType) {
			 switch (ctrlerName) {

			   //  -------  当前目标  -------
				
				case "attacker":
				case "atk":
				 result = $self;
				break; 
				case "attackerCtrler":
				case "atkc":
				 result = $self.getCtrler();
				break;
				case "mc":
				 result = $mc;
				break;

			  //  -------  主人控制器  -------

			    case "owner_fighterCtrler":
				case "ofc":
				 result = $owner.getCtrler();
				break;
				case "owner_mcCtrler":
				case "omc":
				 result = $owner.getCtrler().getMcCtrl();
				break;
				case "owner_effectCtrler":
				case "oec":
				 result = $owner.getCtrler().getEffectCtrl();
				break;
				case "fighterMC":
				 result = $owner.getCtrler().getMcCtrl().getFighterMC();
				break;
				case "owner_fighterBuffCtrler":
				case "obc":
				 result = $owner.getBuffCtrl();
				break;
				case "owner_fighterAction":
				case "oac":
				 result = $owner.getCtrler().getMcCtrl().getAction();
				break;
				case "owner_fighterHitModel":
				case "ofh":
				 result = $owner.getCtrler().hitModel;
				break;
				case "owner_fighterVoiceCtrler":
				case "ovc":
				 result = $owner.getCtrler().getVoiceCtrl(); 
				break;
				case "owner_fighterVO":
				 result = $owner.data;
				break; 
				case "fighterActionState":
				case "fas":
				 result = getClass("fighter.FighterActionState");
				break;
				case "owner_actionState":
				case "oas":
				 result = $owner.actionState;
				break;
				case "owner_display":
				 result = $owner.getDisplay();
				break; 
				case "owner_mc":
				case "omc":
				 result = $omc;
				break;  
				case "owner_main":
				 result = $owner;
				break;

			  //  -------  敌方目标  -------

			   case "target_fighterCtrler":  
			  case "tfc":
			   result = $target.getCtrler();
			  break;
			  case "target_mcCtrler":
			  case "tmc":
			   result = $target.getCtrler().getMcCtrl();
			  break;
			  case "target_effectCtrler":
			  case "tec":
			   result = $target.getCtrler().getEffectCtrl();
			  break;
			  case "target_fighterMC":
			  case "tfmc":
			   result = $target.getCtrler().getMcCtrl().getFighterMC();
			  break;
			  case "target_fighterBuffCtrler":
			  case "tbc":
			   result = $target.getBuffCtrl();
			  break;
			  case "target_fighterAction":
			  case "tac":
			   result = $target.getCtrler().getMcCtrl().getAction();
			  break;
			  case "target_fighterHitModel":
			  case "tfh":
			   result = $target.getCtrler().hitModel;
			  break;
			  case "target_fighterVoiceCtrler":
			  case "tvc":
			   result = $target.getCtrler().getVoiceCtrl();
			  break;
			  case "target_fighterVO":
			   result = $target.data;
			  break;
			  case "target_assisterFighterVO":
				case "tafv":
				 if (isP1) 
				     result = getClass("data.AssisterModel").I.getAssister(getClass("data.GameData").I.p2Select.fuzhu);
				else
				     result = getClass("data.AssisterModel").I.getAssister(getClass("data.GameData").I.p1Select.fuzhu);
			 break;
			 case "target_actionState":
			 case "tas":
			   result = $target.actionState;
			  break;
			  case "target_display":
			   result = $target.getDisplay();
			  break;
			  case "target_mc":
			   result = $tmc;
			  break; 
			  case "target_main":
			   result = $target;
			  break;   		 
			 }
		 } else {
			switch (ctrlerName) {

				  // -------  游戏控制器  -------

                case "mainGame":
				 result = getClass("MainGame").I;
				break; 
				case "gameCtrl":
				case "gc":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I;
				break;
				case "gameState":
				case "gs":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState;
				break;
				case "gameSprites":
				case "sprites":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState.getGameSprites();
				break; 
				case "gameLogic":
				case "logic":
				 result = getClass("ctrl.GameLogic");
				break;
				case "gameLoader":
				case "loader":
				 result = getClass("ctrl.GameLoader");
				break;
				case "gameLogger":
				case "log":
				 result = Log;
				break;
				case "gameEvent":
				case "event":
				 result	= getClass("ctrl.GameEvent");
				break;
				case "gameRender":
				case "render":
				 result = getClass("ctrl.GameRender");
				break;
				case "gameRunData":
				case "runData":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData;
				break;
				case "gameData":
				case "data":
				 result = getClass("data.GameData").I;
				break;
				case "gameMode":
				case "mode":
				 result = getClass("data.GameMode");
				case "gameInputer":
				case "input":
				 result = getClass("input.GameInputer");
				break;  
				break;  
				case "gameUI":
				case "ui":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState.gameUI;
				break;
				case "IGameUI":
				case "iui":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState.gameUI.getUI();
				break; 
				case "uiDisplay":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState.gameUI.getUIDisplay();
				break;

			   // -------  特效控制器  -------

			    case "effectCtrl":
				case "ec":
				 result = getClass("ctrl.EffectCtrl").I;
				break;
				case "effectModel":
				case "em":
				 result = getClass("data.EffectModel");
				break;
				case "effectManager":
				case "manager":
				 result = getClass("utils.EffectManager");
				break; 

			  // -------  角色组 -------

			   case "fighterGroup":
			   case "group":
			    result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p1FighterGroup.currentFighter.getDisplay() ==
				  $owner.getDisplay() ?  getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p1FighterGroup :
				   getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p2FighterGroup;
				break;
				case "target_fighterGroup":
				case "tgroup":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p1FighterGroup.currentFighter.getDisplay() ==
				  $owner.getDisplay() ?  getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p2FighterGroup :
				   getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p1FighterGroup;
				break;

			  //  -------  地图控制器  -------

			   case "mapMain":
			   case "map":
			    result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.map;
			   break;
			   case "mapVO":
			    getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.map.data;
			   break;
			   case "mapModel":
			    result = getClass("data.MapModel").I;
			   break;

			  //  -------  场景控制器  -------
			   
			   case "stageCtrl":
			    result = getClass("MainGame").stageCtrl;
			   break;
			   case "stage":
			    result = getClass("MainGame").stageCtrl.currentStage;

			 //  -------  资源管理器  -------

			  case "assetManager":
			  case "am":
			   result = getClass("ctrl.AssetManager").I;
			  break;

			//  -------  音效控制器  -------

			 case "soundCtrl":
			 case "sound":
			  result = getClass("ctrl.SoundCtrl").I;
			 break;

			//  -------  角色事件库  -------

			 case "fighterEvent":
			 case "fe":
			  result = getClass("fighter.events.FighterEvent");
			 break;
			 case "fighterEventDispatcher":
			 case "fed":
			  result = getClass("fighter.events.FighterEventDispatcher");
			 break;

			//  -------  Kyo工具库  -------

			 case "kyoUtil":
			 case "util":
			  result = getClass("utils.KyoUtils", "kyo");
			 break;
			 case "kyoRandom":
			 case "random":
			  result = getClass("utils.KyoRandom", "kyo");
			 break;
			 case "kyoMath":
			 case "math":
			  result = getClass("utils.KyoMath", "kyo");      
			 break;  

		   //  -------  调试工具类  -------

		    case "debug":
			 result = $debug;
			break;

		  //  -------  精灵控制器  -------

		   case "fighterModel":
		   case "fm":
		    result = getClass("data.EffectModel").I;
		   break;
		   case "fighterKey":
		   case "key":
		    result = $key;
		   break;		 	
		   case "target_fighterKey":
		   case "tkey":
		    result = $tkey;
		   break;
			}	
		   }
		break;
		case _TYPE_BULLET: // 如果自身是飞行物
		  if (ctrlerType) {
			 switch (ctrlerName) {
			   //  -------  当前目标  -------

				case "bullet":
				case "bt":
				 result = $self;
				break;
				case "mc":
				 result = $mc;
				break;

				//  -------  主人控制器  -------
				 
				 case "owner_fighterCtrler":
				case "ofc":
				 result = $ownerFighter.getCtrler();
				break;
				case "owner_mcCtrler":
				case "omc":
				 result = $ownerFighter.getCtrler().getMcCtrl();
				break;
				case "owner_effectCtrler":
				case "oec":
				 result = $ownerFighter.getCtrler().getEffectCtrl();
				break;
				case "fighterMC":
				 result = $ownerFighter.getCtrler().getMcCtrl().getFighterMC();
				break;
				case "owner_fighterBuffCtrler":
				case "obc":
				 result = $ownerFighter.getBuffCtrl();
				break;
				case "owner_fighterAction":
				case "oac":
				 result = $ownerFighter.getCtrler().getMcCtrl().getAction();
				break;
				case "owner_fighterHitModel":
				case "ofh":
				 result = $ownerFighter.getCtrler().hitModel;
				break;
				case "owner_fighterVoiceCtrler":
				case "ovc":
				 result = $ownerFighter.getCtrler().getVoiceCtrl(); 
				break;
				case "owner_fighterVO":
				 result = $ownerFighter.data;
				break; 
				case "fighterActionState":
				case "fas":
				 result = getClass("fighter.FighterActionState");
				break;
				case "owner_actionState":
				case "oas":
				 result = $ownerFighter.actionState;
				break;
				case "owner_display":
				 result = $ownerFighter.getDisplay();
				break; 
				case "owner_mc":
				case "omc":
				 result = $omc;
				break;  
				case "owner_main":
				 result = $owner;
				break;
				case "owner_fighter":
				 result = $ownerFighter;
				break; 

			  //  -------  敌方目标  -------

			   case "target_fighterCtrler":  
			  case "tfc":
			   result = $target.getCtrler();
			  break;
			  case "target_mcCtrler":
			  case "tmc":
			   result = $target.getCtrler().getMcCtrl();
			  break;
			  case "target_effectCtrler":
			  case "tec":
			   result = $target.getCtrler().getEffectCtrl();
			  break;
			  case "target_fighterMC":
			  case "tfmc":
			   result = $target.getCtrler().getMcCtrl().getFighterMC();
			  break;
			  case "target_fighterBuffCtrler":
			  case "tbc":
			   result = $target.getBuffCtrl();
			  break;
			  case "target_fighterAction":
			  case "tac":
			   result = $target.getCtrler().getMcCtrl().getAction();
			  break;
			  case "target_fighterHitModel":
			  case "tfh":
			   result = $target.getCtrler().hitModel;
			  break;
			  case "target_fighterVoiceCtrler":
			  case "tvc":
			   result = $target.getCtrler().getVoiceCtrl();
			  break;
			  case "target_fighterVO":
			   result = $target.data;
			  break;
			  case "target_assisterFighterVO":
				case "tafv":
				 if (isP1) 
				     result = getClass("data.AssisterModel").I.getAssister(getClass("data.GameData").I.p2Select.fuzhu);
				else
				     result = getClass("data.AssisterModel").I.getAssister(getClass("data.GameData").I.p1Select.fuzhu);
			 break;
			 case "target_actionState":
			 case "tas":
			   result = $target.actionState;
			  break;
			  case "target_display":
			   result = $target.getDisplay();
			  break;
			  case "target_mc":
			   result = $tmc;
			  break; 
			  case "target_main":
			   result = $target;
			  break;
			 }
		 } else {
			switch (ctrlerName) {

				// -------  游戏控制器  -------

                case "mainGame":
				 result = getClass("MainGame").I;
				break; 
				case "gameCtrl":
				case "gc":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I;
				break;
				case "gameState":
				case "gs":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState;
				break;
				case "gameSprites":
				case "sprites":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState.getGameSprites();
				break; 
				case "gameLogic":
				case "logic":
				 result = getClass("ctrl.GameLogic");
				break;
				case "gameLoader":
				case "loader":
				 result = getClass("ctrl.GameLoader");
				break;
				case "gameLogger":
				case "log":
				 result = Log;
				break;
				case "gameEvent":
				case "event":
				 result	= getClass("ctrl.GameEvent");
				break;
				case "gameRender":
				case "render":
				 result = getClass("ctrl.GameRender");
				break;
				case "gameRunData":
				case "runData":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData;
				break;
				case "gameData":
				case "data":
				 result = getClass("data.GameData").I;
				break;
				case "gameMode":
				case "mode":
				 result = getClass("data.GameMode");
				case "gameInputer":
				case "input":
				 result = getClass("input.GameInputer");
				break;  
				break;  
				case "gameUI":
				case "ui":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState.gameUI;
				break;
				case "IGameUI":
				case "iui":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState.gameUI.getUI();
				break; 
				case "uiDisplay":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameState.gameUI.getUIDisplay();
				break;

			   // -------  特效控制器  -------

			    case "effectCtrl":
				case "ec":
				 result = getClass("ctrl.EffectCtrl").I;
				break;
				case "effectModel":
				case "em":
				 result = getClass("data.EffectModel");
				break;
				case "effectManager":
				case "manager":
				 result = getClass("utils.EffectManager");
				break; 

			  // -------  角色组 -------

			   case "fighterGroup":
			   case "group":
			    result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p1FighterGroup.currentFighter.getDisplay() ==
				  $owner.getDisplay() ?  getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p1FighterGroup :
				   getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p2FighterGroup;
				break;
				case "target_fighterGroup":
				case "tgroup":
				 result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p1FighterGroup.currentFighter.getDisplay() ==
				  $owner.getDisplay() ?  getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p2FighterGroup :
				   getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.p1FighterGroup;
				break;

			  //  -------  地图控制器  -------

			   case "mapMain":
			   case "map":
			    result = getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.map;
			   break;
			   case "mapVO":
			    getClass("ctrl.game_ctrls.GameCtrl").I.gameRunData.map.data;
			   break;
			   case "mapModel":
			    result = getClass("data.MapModel").I;
			   break;

			  //  -------  场景控制器  -------
			   
			   case "stageCtrl":
			    result = getClass("MainGame").stageCtrl;
			   break;
			   case "stage":
			    result = getClass("MainGame").stageCtrl.currentStage;

			 //  -------  资源管理器  -------

			  case "assetManager":
			  case "am":
			   result = getClass("ctrl.AssetManager").I;
			  break;

			//  -------  音效控制器  -------

			 case "soundCtrl":
			 case "sound":
			  result = getClass("ctrl.SoundCtrl").I;
			 break;

			//  -------  角色事件库  -------

			 case "fighterEvent":
			 case "fe":
			  result = getClass("fighter.events.FighterEvent");
			 break;
			 case "fighterEventDispatcher":
			 case "fed":
			  result = getClass("fighter.events.FighterEventDispatcher");
			 break;

			//  -------  Kyo工具库  -------

			 case "kyoUtil":
			 case "util":
			  result = getClass("utils.KyoUtils", "kyo");
			 break;
			 case "kyoRandom":
			 case "random":
			  result = getClass("utils.KyoRandom", "kyo");
			 break;
			 case "kyoMath":
			 case "math":
			  result = getClass("utils.KyoMath", "kyo");      
			 break;  

		   //  -------  调试工具类  -------

		    case "debug":
			 result = $debug;
			break;

		  //  -------  精灵控制器  -------

		   case "fighterModel":
		   case "fm":
		    result = getClass("data.EffectModel").I;
		   break;
		   case "fighterKey":
		   case "key":
		    result = $key;
		   break;		 	
		   case "target_fighterKey":
		   case "tkey":
		    result = $tkey;
		   break;
			}	
		   }
	 }	
	} catch (e:Error) {}	
	
	return result;
}

//////////////////////////////////////////////////////////////////////////////////////////

//                                    调试相关方法                   

//////////////////////////////////////////////////////////////////////////////////////////

/**
 * 报错信息
 */
function errorMsg(msg:String):void {
	$debug.errorMsg(msg);
}	

/**
 * 日志
 */
function Log(msg:String):void {
	getClass("utils.GameLoger").log(msg);
}

//////////////////////////////////////////////////////////////////////////////////////////

//                                     实用补充相关方法                   

//////////////////////////////////////////////////////////////////////////////////////////


/**
 * 获得双方血量差
 * @return 返回双方血量差
 */
function get $hpDiff():int {
	return Math.abs($owner.hp - $target.hp);
}

/**
 * 获得自身血量比例
 * @return 返回自身血量比例
 */
function get $hpRate():Number {
	return $owner.hp / $owner.hpMax;
}

/**
 * 判断是否是 P1
 * @return 返回自身是否是 玩家1 操作
 */
function get isP1():Boolean {
	return $self.team.id == 1;
}

var _initPauseEvent:Boolean;

/**
 * 初始化暂停事件
 */
function initPauseEvent():void {
	var gameEvent:Class = getClass("events::GameEvent");

   // 添加事件
	gameEvent.addEventListener("PAUSE_GAME", _onPauseGame_);
    gameEvent.addEventListener("RESUME_GAME", _onResumeGame_);
	
	_initPauseEvent = true;
}

var _isPauseGame:Boolean;

/**
 * 游戏是否暂停
 * @return 游戏是否暂停的布尔值 (Boolean 类型)
 */
function get isPause():Boolean {
   // 如果: 没有初始化暂停事件 则:: 初始化事件	
	if (!_initPauseEvent) initPauseEvent();

   // 返回暂停状态	
	return _isPauseGame;
}

/**
 * 设置暂停 (私有)
 */
function _onPauseGame_(e:Event = null):void {
	// 变量
	var gameEvent:Class = getDefinitionByName("net.play5d.game.bvn.events::GameEvent") as Class;
	
   // 如果当前层级不存在 则: 删除当前侦停器
	if (!this) {
		gameEvent.removeEventListener("PAUSE_GAME",_onPauseGame_);
	}

	_isPauseGame = true;
}

/**
 * 设置恢复 (私有)
 */
function _onResumeGame_(e:Event = null):void {
	// 变量
	var gameEvent:Class = getDefinitionByName("net.play5d.game.bvn.events::GameEvent") as Class;
	
   // 如果当前层级不存在 则: 删除当前侦停器
	if (!this) {
		gameEvent.removeEventListener("PAUSE_GAME", _onResumeGame_);
	}
	_isPauseGame = false;
}

/**
 * 检测是否存在黑幕
 * *@return 是否存在黑幕的布尔值 (Boolean 类型)
 */
function get isBlackCurtain():Boolean {
	var display:DisplayObject = $ownerFighter.getDisplay().parent.parent.parent.getChildAt(0);
	var BlackBackView:String = "net.play5d.game.bvn.views.effects::BlackBackView";
	
	return getQualifiedClassName(display) ==  BlackBackView;
}

/**
 * 检测角色是否处于幽步状态
 * @return 幽步类型 0:幽步 1:幽跃 2:幽坠 (int 类型) 
 * 注:如果不处于状态则返回false (Boolean 类型) 
 */
function get isGhostStep():int {
	var mc:MovieClip = $omcFighter;
    var selfInGhostStep:Boolean = isBlackCurtain && ["走","跳","落"].indexOf(mc.currentLabel) != -1;

	if (selfInGhostStep) {
        switch (mc.currentLabel) {
		   case "走":
		    return 1;	
		   case "跳":
		    return 2;
		   case "落":
		    return 3;
		   default:
		    return 0;
	    }
    }

    return 0;	
}

/**
 * 检测敌方角色是否处于幽步状态
 * @return 幽步类型 0:幽步 1:幽跃 2:幽坠 (int 类型) 
 * 注:如果不处于状态则返回false (Boolean 类型)
 */
function get targetIsGhostStep():* {
	var mc:MovieClip = $tmc;
    var selfInGhostStep:Boolean = isBlackCurtain && ["走","跳","落"].indexOf(mc.currentLabel) != -1;

    if (selfInGhostStep) {
        switch (mc.currentLabel) {
		   case "走":
		    return 0;	
		   case "跳":
		    return 1;
		   case "落":
		    return 2;
		   default:
		    return false;
	    }
    }

    return false;	
}

/**
 * 检测输入对象是否处于幽步状态
 * @return 幽步类型 0:幽步 1:幽跃 2:幽坠 (int 类型) 
 * 注:如果不处于状态则返回false (Boolean 类型)
 */
/*
function checkTargetIsGhostStep(target:*):* {
	var mc:MovieClip = _getType(target) == _TYPE_FIGHTER_MAIN ? 
	       findBvnMovieClip(target.getDisplay() as MovieClip) : target.getDisplay() as MovieClip;
		   

    var selfInGhostStep:Boolean = isBlackCurtain && ["走","跳","落"].indexOf(mc.currentLabel) != -1;

    if (selfInGhostStep) {
        switch (mc.currentLabel) {
		   case "走":
		    return 1;	
		   case "跳":
		    return 2;
		   case "落":
		    return 3;
		   default:
		    return false;
	    }
    }

    return false;	
} 
 **暂时封存 等有空再完善**
*/

/**
 * 是否是处于训练模式
 * @return 是否处于训练模式的布尔值 (boolean 类型)
 */ 
function get isTraningMode():Boolean {
	
    var gameMode:Class = getClass("data::GameMode");

	try {
		if (gameMode.currentMode == gameMode.TRAINING)
			return true;
		else if (gameMode.isTraining != null && gameMode.isTraining()) {
			return true;
		} else if (gameMode.isTrainingMode != null && gameMode.isTrainingMode())
			return true;
	} catch (e:Error) {
		return false;
      }
	  
	return false;  
}

/**
 * 播放随机音效并提供自定义功能
 * @param obj 包含以下属性的对象：
 * - sounds: 要播放的声音数组（可以包含多个Sound对象），默认为空数组
 * - volume: 音量大小，范围为0.0到1.0，默认为1.0
 * - pro: 播放概率 按百分比计算 100-0 (int 类型, 默认: 100) 
 * - conditions: 自定义播放条件的回调函数，返回布尔值 (Function 类型, 默认:null)
 * - callback: 播放完成后的回调函数 (Function 类型, 默认:null)
 * - returnChannel: 是否返回SoundChannel对象，(Boolean类型, 默认:false)
 * @return 如果returnChannel为true，返回SoundChannel对象 (Boolean 类型, 默认:null)
 * @example
 * var sound1:Sound = new Sound(new URLRequest("sound1.mp3"));
 * var sound2:Sound = new Sound(new URLRequest("sound2.mp3"));
 * var obj:Object = {
 *     sounds: [sound1, sound2],
 *     volume: 0.5,
 *     pro: 50
 *     conditions: function():Boolean { return true; },
 *     callback: function():void { trace("playRandomSound::音效播放完成！"); },
 *     returnChannel: true
 * };
 * var soundChannel:SoundChannel = playRandomSound(obj);
 * soundChannel.soundTransform = new SoundTransform(obj.volume);
 * @example
 * var obj2:Object = {
 *     sounds: [sound1, sound2]
 * };
 * playRandomSound(obj2);
 */
function playRandomSound(obj:Object = null):SoundChannel {
   
   // 如果不设置任何参数 	
	if (obj == null) {
		trace("playRandomSound:: 未设置参数");
		return null;
	}
	
   // 声音数组
	var sounds:Array = obj.sounds || [];
	
   // 音量大小，默认为1.0
    var volume:Number = obj.volume !== undefined ? obj.volume : 1.0;
	
	var pro:int = obj.pro || 100;
	
   // 自定义播放条件的回调函数，默认为null
    var conditions:Function = obj.conditions || null;
	
   // 播放完成后的回调函数，默认为null
    var callback:Function = obj.callback || null;
	
   // 是否返回SoundChannel对象，默认为false
    var returnChannel:Boolean = obj.returnChannel || false;
	
   // 声音播放通道
    var soundChannel:SoundChannel;

   // 如果声音数组为空
    if (sounds.length == 0) { 
		trace("playRandomSound:: 声音数组为空。"); 
		return null; 
	}
	
   // 判断是否满足概率	
	if (Math.random() > pro / 100) {
	   	return null;	
	}

   // 判断是否满足播放条件
    if (conditions != null && !conditions()) {
		 return null; 
	}

   // 随机选择一个声音
    var sound:Sound = new sounds[int(Math.random() * sounds.length)]() as Sound;

   // 创建SoundTransform对象以控制音量
    var soundTransform:SoundTransform = new SoundTransform(volume);

   // 播放声音
    soundChannel = sound.play();
    soundChannel.soundTransform = soundTransform;

  // 监听声音播放完成事件
    if (callback != null) {
        soundChannel.addEventListener(Event.SOUND_COMPLETE, function(event:Event):void {
            soundChannel.removeEventListener(Event.SOUND_COMPLETE, arguments.callee);
            callback();
        });
    }

   // 根据returnChannel的值决定是否返回SoundChannel对象
    return returnChannel ? soundChannel : null;
}

/**
 * 检查给定的值是否具有负号。
 * 支持的类型包括 Number、int 和 uint。
 *
 * @param value 要检查的值。(任意类型)
 * @return 返回是否带有符号的布尔值。(Boolean 类型)
 */
function hasNegativeSign(value:*):Boolean {
   // 确保值是 Number、int 或 uint 类型
    if (value is Number || value is int || value is uint)
       // 将值转换为字符串并检查第一个字符是否为负号
        return value.toString().charAt(0) == "-";

   // 如果值不是支持的类型，则返回 false
    return false;
}

//////////////////////////////////////////////////////////////////////////////////////////

//                                     特效类实用方法                   

//////////////////////////////////////////////////////////////////////////////////////////

var _shadows:Dictionary;
var _isRenderShadows:Boolean;

/**
 * 添加残影效果
 * @param params 参数对象，包含以下属性 (Object 类型):
 *   - color:Array [必须] 颜色偏移数组([红,绿,蓝])，取值范围0-255
 *   - target:* [可选] 要添加残影的目标对象，默认使用当前对象($self)
 *   - blur:Object [可选] 模糊参数 {x:int, y:int}
 *   - alpha:Number [可选] 初始透明度，默认0.8
 *   - zoom:Object [可选] 缩放参数 {x:Number, y:Number, speed:Number，
 *     anchorX:Number, anchorY:Number}
 *   - time:int [可选] 残影存活时间，默认10帧
 *   - fadeSpeed:Number [可选] 淡出速度，默认0.01
 * @return 无返回值
 */
function addShadow(params:Object = null):* {

   // 检查残影开关
	if (!getClass("ctrl.EffectCtrl").SHADOW_ENABLED)
	    return;

   // 参数基础检查
    if (!params) {
        trace("addShadow:: what you doing???");
        return;
    }
    
   // 初始化残影存储对象
    if (!_shadows) _shadows = new Dictionary();  // _shadows结构: {target1: {bitmap:[...]}, target2: {...}}
    
   // 颜色参数处理 -------------------------------------------------
    var color:Array;
    if (params.color) {
       // 类型校验
        if (!(params.color is Array)) {  // 修复原代码中的判断语法
            trace("SFALIB.addShadow:: color is not an Array type!!");
            return;
        }
        
       // 数组长度校验
        if (params.color.length < 3) {
            trace("SFALIB.addShadow:: The number of parameters for color is incorrect.");
            return;
        }
        
        color = params.color;
    } else {
        trace("SFALIB.addShadow:: color is null");
        return;
    }
    
   // 颜色分量类型校验
    if (!(color[0] is int) ||
        !(color[1] is int) ||
        !(color[2] is int)) {
        trace("SFALIB.addShadows:: Invalid number, please use int Type.");
        return;
    }

   // 目标对象处理 -------------------------------------------------
    var target:*;
    if (params.target != null) {
       // 目标类型校验
        if (_getType(params.target) == _TYPE_UNKNOWN) {
            trace("SFALIB.addShadow:: target is not support Type!!");
            return;
        }     
        target = params.target;
    } else {
        target = $self;  // 默认使用当前对象
    }

   // 获取显示对象 -------------------------------------------------
    try {
        var display:DisplayObject = target.getDisplay();  // 获取目标的可显示对象
    } catch (e:ReferenceError) {
        errorMsg("SFALIB.addShadow:: can find Display of Target!!");
        return;
    }

   // 检测残影是否超过数量限制 --------------------------------------
    if (checkShadowIsLimit(target)) return;

   // 颜色变换设置 -------------------------------------------------
    var ct1:ColorTransform = new ColorTransform();
    var kyoUtil:Class = getClass("utils.KyoUtils", "kyo");
    ct1.redOffset = color[0];    // 红色通道偏移
    ct1.greenOffset = color[1];  // 绿色通道偏移
    ct1.blueOffset = color[2];   // 蓝色通道偏移
    
   // 生成残影位图 -------------------------------------------------
    var shadowMap:Bitmap = null;
	try {
       // 使用工具类绘制带颜色变换的位图
        shadowMap = kyoUtil.drawDisplay(display, true, true, 0, ct1) as Bitmap;
    } catch (e:Error) {
        errorMsg("SFALIB.addShadow:: can draw Display!!");
        return;
    }

	if (!shadowMap) return;

   // 透明度设置 ---------------------------------------------------
    var alpha:Number = 0.8;  // 默认透明度
    if (params.alpha) {
        if (!(params.alpha is Number)) {  // 修复判断语法
            trace("SFALIB.addShadow:: alpha is not Number type!!");
            return;
        }
        alpha = params.alpha;
    }

   // 生命周期参数 -------------------------------------------------
    var life:int = 10;  // 默认存活时间（帧数）
    if (params.time && (params.time is int)) 
        life = params.time;

    var fadeSpeed:Number = 0.01;  // 默认淡出速度
    if (params.fadeSpeed && (params.fadeSpeed is Number)) 
        fadeSpeed = params.fadeSpeed;

    shadowMap.alpha = alpha;  // 设置初始透明度
  ;  
   // 模糊效果处理 -------------------------------------------------
    var shadowBlur:BlurFilter = null;
	if (params.blur && 
	   params.blur.x != undefined && 
       params.blur.y != undefined) {
    
   // 确保质量参数在合理范围内
    var quality:int = (params.blur.quality is int) ?
            (params.blur.quality >= 1 && params.blur.quality <= 3) ? 
            params.blur.quality : 1 : 1;

    // 确保模糊参数是数字类型
    if (!(params.blur.x is int) || !(params.blur.y is int)) {
        trace("SFALIB.addShadow:: the Type of blur is not int !!");
        return;
    }

    // 创建模糊滤镜（水平/垂直模糊量，默认质量1）
    shadowBlur = new BlurFilter(params.blur.x, params.blur.y, quality);            
  }

// 应用模糊滤镜到位图数据
if (shadowBlur != null && shadowMap.bitmapData) {
    shadowMap.bitmapData.applyFilter(
        shadowMap.bitmapData,
        shadowMap.bitmapData.rect,
        new Point(),
        shadowBlur
    );
}


  // 尺寸缩放 -------------------------------------------------
   var zoom:Object = null;
   if (params.zoom) {
   // 参数验证加强
    if (!(params.zoom is Object)) {
        trace("SFALIB.addShadow:: zoom parameter requires Object type!");
        return;
    }
    
   // 必需参数检查
    if (typeof params.zoom.x == "undefined" || 
        typeof params.zoom.y == "undefined") {
        trace("SFALIB.addShadow:: zoom object requires x/y properties!");
        return;
    }
    
   // 类型安全校验
    if (!(params.zoom.x is Number) || 
        !(params.zoom.y is Number)) {
        trace("SFALIB.addShadow:: zoom.x/y must be Number type!");
        return;
    }
    
   // 初始化缩放参数
    zoom = {
        targetX: params.zoom.x * target.direct,  // 最终目标缩放值
        targetY: params.zoom.y,
        speed: params.zoom.speed || 0.05,       // 默认速度调整为0.05
        originalX: display.scaleX,             // 记录原始缩放值
        originalY: display.scaleY,
		direct: target.direct,  // 角色朝向
		anchorX: params.zoom.anchorX || 0,  // X轴锚点 0=左侧 1=右侧
        anchorY: params.zoom.anchorY || 0   // Y轴锚点 0=顶部 1=底部
    };
}

   // 存储残影数据 -------------------------------------------------
    if (!_shadows[target]) {
        _shadows[target] = {};
        _shadows[target].bitmap = [];  // 存储该目标的所有残影位图
    }    
    var arrays:Array = _shadows[target].bitmap;

	shadowMap.name = "sd"+arrays.length;  // 给位图命名

   // 计算显示位置 -------------------------------------------------
    var rect:Rectangle = display.getBounds(display) as Rectangle;
    shadowMap.x = display.x + rect.x * display.scaleX;  // 计算X坐标（考虑缩放）
    shadowMap.y = display.y + rect.y;                   // 计算Y坐标

   // 同步缩放比例
    shadowMap.scaleX = display.scaleX;
    shadowMap.scaleY = display.scaleY;

   // 添加显示对象
    display.parent.addChildAt(shadowMap, 0);

	var finalParams:Object = {
        map: shadowMap,      // 位图对象
        time: life,          // 剩余存活时间
        fadeSpeed: fadeSpeed // 透明度衰减速度
    }
    
   // 如果: 缩放参数存在 则:: 将其添加到最终参数中
	if (zoom) finalParams["zoom"] = zoom;  // 缩放参数

   // 保存残影参数
    arrays.push(finalParams);

   // 初始化渲染循环 -----------------------------------------------
    if (!_isRenderShadows) {
        addRenderAnimateFunc(renderShadows);  // 添加残影渲染到动画循环
        _isRenderShadows = true;    
    }    
}

/**
 * 残影渲染器
 */
function renderShadows():void {
   // 遍历所有对象的残影
    for each (var shadowData:Object in _shadows) {
        var shadowArray:Array = shadowData.bitmap;
		const _approachValue:Function = function(current:Number, target:Number, step:Number):Number {
			if (current < target) 
			  return Math.min(current + step, target);
			else
			  return Math.max(current - step, target);
		}
        
       // 倒序遍历防止删除元素后索引错位
        var i:int = shadowArray.length;
        while(i--) {
            var shadow:Object = shadowArray[i];
            
           // 减少残影存活时间
            shadow.time--;

      // 缩放效果
	   if (shadow.zoom) {
		   var zoom:Object = shadow.zoom;
           var map:DisplayObject = shadow.map;
		
		  // 记录当前状态
      	   var currentX:Number = map.x;
           var currentY:Number = map.y;
           var currentScaleX:Number = map.scaleX;
           var currentScaleY:Number = map.scaleY;
		 
		  // 计算新缩放值
           var deltaX:Number = (zoom.targetX - zoom.originalX) * zoom.speed;
           var newScaleX:Number = _approachValue(currentScaleX, zoom.targetX, Math.abs(deltaX));
	        newScaleX = (newScaleX * currentScaleX < 0) ? 0 : Math.abs(newScaleX);
            newScaleX = Math.max(newScaleX, 0.01) * zoom.direct;
		  var deltaY:Number = (zoom.targetY - zoom.originalY) * zoom.speed;
          var newScaleY:Number = _approachValue(currentScaleY, zoom.targetY, Math.abs(deltaY));
	       newScaleY = (newScaleY * currentScaleY < 0) ? 0 : Math.abs(newScaleY);
           newScaleY = Math.max(newScaleY, 0.01);
	   
	    // 计算锚点偏移量
         var rect:Rectangle = map.getBounds(map.parent);
         var baseWidth:Number = rect.width / currentScaleX;  // 原始未缩放宽度
         var baseHeight:Number = rect.height / currentScaleY; // 原始未缩放高度
	    
		// 计算位置补偿
         var offsetX:Number = baseWidth * (newScaleX - currentScaleX) * zoom.anchorX;
         var offsetY:Number = baseHeight * (newScaleY - currentScaleY) * zoom.anchorY;
	   // 应用新的位置和缩放
         map.x = currentX - offsetX * zoom.direct;  // 考虑角色朝向
         map.y = currentY - offsetY;
         map.scaleX = newScaleX;      // 保持朝向同步
         map.scaleY = newScaleY;
	    }
           if (shadow.time <= 0) {

		   // 应用淡出效果
            shadow.map.alpha -= shadow.fadeSpeed;

		   // 当对象完全透明时移除残影
			if (shadow.map.alpha <= 0) {
                if (shadow.map.parent) {
                    shadow.map.parent.removeChild(shadow.map);
                }
                shadow.map.bitmapData.dispose(); // 释放位图内存
                shadowArray.splice(i, 1); // 移除数组元素
             }
		   }           
        }
    }
}

var _shadowIng:Boolean;
var _startShadowParams:Object;

/**
 * 开始残影(持续)
 */
function startShadow(params:Object):void {
   // 检测是否处于持续残影中与残影开关
	if (_shadowIng || !getClass("ctrl.EffectCtrl").SHADOW_ENABLED) 
	    return;
    
   // 关键参数存在验证	
	if ( !params.color ||
	     !params.color is Array ||
		 !params.color.length >= 3 ||
	     !params.time ||
		 !params.time is int ) {
		trace("SFALIB.startShadow:: key parameter is invalid!");
		return;
    }

  // 残影相关常量	
	var freq:int = params.freq || 5000;
	var config:Class = getClass("GameConfig"); 
	var timer:int = freq / config.FPS_GAME;

   // 更新改变后的频率
	params.freq = timer;

	params.orignalFreq = timer;	
    
   // 如果: 持续残影参数存在 则:: 初始化对象
	if (!_startShadowParams) _startShadowParams =  {};
	
   // 赋值参数	
	_startShadowParams = params;

   // 开始渲染持续残影
	_shadowIng = true;
	this.addEventListener(Event.ENTER_FRAME, renderStartShadow);
	addShadow(_startShadowParams);
}

/**
 * 结束残影
 */
function removeShadow():void  {
	if (!_shadowIng) return;
	_shadowIng  = false;
}

/**
 * 渲染持续残影
 */
function renderStartShadow(e:Event = null):void {
	if (isPause)return;
	if (!_shadowIng) {
		this.removeEventListener(Event.ENTER_FRAME,renderStartShadow);
		return;
	}
    var params:Object = _startShadowParams;
	

	if (--params.freq <= 0) {
	    addShadow(_startShadowParams);
	    params.freq = params.orignalFreq; // 重置 countFreq 以便下次使用
	}	

}
var _shadowNumLimit:int = 20;

/**
 * 设置残影数量限制
 * @param num 限制数量 (int 类型)
 */
function setShadowNumLimit(num:int):void {
	_shadowNumLimit = num;
}

/**
 * 检测指定目标的残影数量是否达到上限
 * @param target 需要检测的目标对象
 * @return 是否达到数量限制的布尔值
 */
function checkShadowIsLimit(target:*):Boolean {
    // 确保阴影存储字典已初始化
    if (!_shadows) return false;
    
    // 获取目标对应的残影数据
    var shadowData:Object = _shadows[target];
    
    // 如果目标不存在或没有残影数据，返回未超限
    if (!shadowData || !shadowData.bitmap) return false;
    
    // 直接获取该目标的残影数组并检查长度
    return shadowData.bitmap.length >= _shadowNumLimit;
}


//////////////////////////////////////////////////////////////////////////////////////////

//                                    渲染相关方法                   	

//////////////////////////////////////////////////////////////////////////////////////////

/**
 * 物理帧渲染
 */
function render():void {

    // 反复调用 delayCall 才能实现每帧执行一次的效果
	$self.delayCall(render, 1);
    
   // 渲染所添加的物理帧函数	
	doRenderFuncs();
}


/**
 * 动画帧渲染
 */
function renderAnimate():void {

   // 反复调用 setAnimateFrameOut 才能实现每帧执行一次的效果
	$self.setAnimateFrameOut(renderAnimate, 1);

   // 渲染添加的动画帧函数
	doRenderAnimateFuncs();
}


// 自定义物理帧渲染函数列表
var renderFuncs:Dictionary = new Dictionary();

// 自定义动画帧渲染函数列表
var renderAnimateFuncs: Dictionary = new Dictionary();

/**  
 * 添加指定的自定义动画帧渲染函数
 * @param func 要添加的函数 (function 类型)
 * @param removeWhenBankai 是否移除在变身形态时执行的函数 (boolean 类型)
 */
function addRenderFunc(func:Function, removeWhenBankai:Boolean = true): void { 
	if (_getSelfType() == _TYPE_ASSISTER || _getSelfType() == _TYPE_FIGHTER_ATTACKER)
	    removeWhenBankai = false;

	renderFuncs[func] = removeWhenBankai ? $ownerFighter.getDisplay().currentFrame : 1;
}

/**  
 * 移除指定的自定义物理帧渲染函数
 * @param func 要移除的函数 (function 类型)
 */
function removeRenderFunc(func:Function): void {
	delete renderFuncs[func];
}

/** 
 * 渲染添加的自定义物理帧函数
 */
function doRenderFuncs():void {
	for (var func: Function in renderFuncs) {

		// 既不是初始化帧函数，也不是当前变身形态帧的函数，那么就移除
		if (renderFuncs[func] != 1 && renderFuncs[func] != $ownerFighter.getDisplay().currentFrame) {
			removeRenderFunc(func);
		} else {
			func.call();
		}
	}
}

/**  
 * 添加指定的自定义动画帧渲染函数
 * @param func 要添加的函数 (function 类型)
 * @param removeWhenBankai 是否移除在变身形态时执行的函数 (boolean 类型)
 */
function addRenderAnimateFunc(func:Function, removeWhenBankai:Boolean = true):void {
	if (_getSelfType() == _TYPE_ASSISTER || _getSelfType() == _TYPE_FIGHTER_ATTACKER)
	    removeWhenBankai = false;

	renderAnimateFuncs[func] = removeWhenBankai ? this.currentFrame : 1;
}

/**  
 * 移除指定的自定义动画帧渲染函数
 * @param func 要移除的函数 (function 类型)
 */
function removeRenderAnimateFunc(func:Function):void {
	delete renderAnimateFuncs[func];
}

/** 
 * 渲染添加的自定义动画帧函数
 */
function doRenderAnimateFuncs():void {
	
	for (var func: Function in renderAnimateFuncs) {

	   // 既不是初始化帧函数，也不是当前变身形态帧的函数，那么就移除
		if (renderAnimateFuncs[func] != 1 && renderAnimateFuncs[func] != $ownerFighter.getDisplay().currentFrame) {
			removeRenderAnimateFunc(func);
		} else {
			func.call();
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////

//                                    初始化                   		

//////////////////////////////////////////////////////////////////////////////////////////

// 初始化 SFALIB
initlizeSFALIB();