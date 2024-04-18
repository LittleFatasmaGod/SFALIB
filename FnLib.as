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

// 最新地址
// https://raw.githubusercontent.com/5DPLAY-Game-Studio/FnLib/main/FnLib.as
// https://gitee.com/play5d_game_studio/fn-lib/raw/main/FnLib.as

// 使用方法：
// 确保 FnLib.as 文件放在 fla 文件同级目录下，
// 在 人物/辅助/独立道具/飞行道具 第一帧，
// 加入 include "FnLib.as" 语句，
// 即可在源文件中使用本文件提供的快捷访问属性。

//////////////////////////////////////////////////////////////////////////////////////////
// 导入包

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.utils.getDefinitionByName;

//////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////////////
// 信息

const IS_PRINT:Boolean = false;

const VERSION:String = "0.0.3";			// 版本
const AUTHOR :String = "5dplay";		// 作者
const DATE   :String = "2024.04.15";	// 日期

//////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////////////
// 获取所需全部包名引用

const PKG_NAME_FIGHTER       :String = "net.play5d.game.bvn.fighter::"
const PKG_NAME_CTRL_GAMECTRLS:String = "net.play5d.game.bvn.ctrl.game_ctrls::"

//////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////////////
// 获取类引用

var FighterMain    :Class = getDefinitionByName(PKG_NAME_FIGHTER + _TYPE_FIGHTER_MAIN    );
var Assister       :Class = getDefinitionByName(PKG_NAME_FIGHTER + _TYPE_ASSISTER        );
var Bullet         :Class = getDefinitionByName(PKG_NAME_FIGHTER + _TYPE_BULLET          );
var FighterAttacker:Class = getDefinitionByName(PKG_NAME_FIGHTER + _TYPE_FIGHTER_ATTACKER);

var GameCtrl:Class = getDefinitionByName(PKG_NAME_CTRL_GAMECTRLS + "GameCtrl");

//////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////////////
// 私有变量及函数，以【_】开头，不推荐使用，仅作为【FnLib.as】文件内部使用

// 自身引用
var _this:MovieClip = this as MovieClip;

const _TYPE_FIGHTER_MAIN    :String = "FighterMain";
const _TYPE_ASSISTER        :String = "Assister";
const _TYPE_BULLET          :String = "Bullet";
const _TYPE_FIGHTER_ATTACKER:String = "FighterAttacker";
const _TYPE_UNKNOWN         :String = "Unknown";

const _NOT_APPLICABLE:String = "[N/A]";

/**
 * 初始化
 */
function _initialize():void {
	_print();
}

/**
 * 打印自身信息
 */
function _print():void {
	if (!IS_PRINT) {
		return;
	}
	
	var text:String = 
		"[FnLib]::{\n\t" + 
			"Ver:" + VERSION + ", Author:" + AUTHOR + ", Date:" + DATE + "\n\t" + 
			"SelfType:" + _getSelfType() + ", Name:" + $name + "\n" + 
		"}"
	;
	
	trace(text);
}

var _selfType:String = null;
/**
 * 获取自身类型
 * 
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
		var cls :Class  = o.cls  as Class;
		
		if (sp is cls) {
			type = o.type as String;
			
			break;
		}
	}
	
	return type;
}

//////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////////////
// 公有函数，对外接口

var _self:* = null;
/**
 * 获得自身类引用
 * 
 * @return 返回自身 Class
 */
function get $self():* {
	if (_self) {
		return _self;
	}
	
	var gameStage:* = GameCtrl.I.gameState;
	var gameSprites:* = gameStage.getGameSprites();
	
	for each (var sp:* in gameSprites) {
		var d:DisplayObject = sp.getDisplay();
		
		// 等于 this 可获取 FighterAttacker Bullet Assister
		// 等于 this.parent 可获取 FighterMain
		if (d == _this || d == _this.parent) {
			_self = sp;
			
			break;
		}
	}
	
	return _self;
}

var _owner:* = null;
/**
 * 获得最顶主人类引用，始终返回 FighterMain
 * 
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

var _target:* = null;
/**
 * 获得对手主人类引用，始终返回 FighterMain
 * 
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
 * 获得自身名称
 * 
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
 * 获得双方血量差
 * 
 * @return 返回双方血量差
 */
function get $hpDiff():int {
	return Math.abs($owner.hp - $target.hp);
}

/**
 * 获得自身血量比例
 * 
 * @return 返回自身血量比例
 */
function get $hpRate():Number {
	return $owner.hp / $owner.hpMax;
}

/**
 * 判断是否是 P1
 * 
 * @return 返回自身是否是 玩家1 操作
 */
function isP1():Boolean {
	return $self.team.id == 1;
}

//////////////////////////////////////////////////////////////////////////////////////////




//////////////////////////////////////////////////////////////////////////////////////////
// 初始化

_initialize();

//////////////////////////////////////////////////////////////////////////////////////////