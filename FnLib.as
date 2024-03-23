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

//////////////////////////////////////////////////////////////////////////////////////////
// 导入包

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.utils.getDefinitionByName;

//////////////////////////////////////////////////////////////////////////////////////////

const IS_PRINT:Boolean = false;

const VERSION:String = "0.0.2";			// 版本
const AUTHOR :String = "5dplay";		// 作者
const DATE   :String = "2024.03.23";	// 日期



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
const _TYPE_UNKNOWN         :String = "UNKNOWN";

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
 */
function _getSelfType():String {
	if (_selfType) {
		return _selfType;
	}
	
	_selfType = _TYPE_UNKNOWN;
	
	if ($self is FighterMain) {
		_selfType = _TYPE_FIGHTER_MAIN;
	}
	else if ($self is Assister) {
		_selfType = _TYPE_ASSISTER;
	}
	else if ($self is Bullet) {
		_selfType = _TYPE_BULLET;
	}
	else if ($self is FighterAttacker) {
		_selfType = _TYPE_FIGHTER_ATTACKER;
	}
	
	return _selfType;
}

//////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////////////
// 公有函数，对外接口

var _self:* = null;
/**
 * 获得自身类引用
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
	
	if ($self is FighterMain) {
		_owner = $self;
	}
	else if ($self is Assister) {
		_owner = $self.getOwner();
	}
	else if ($self is Bullet) {
		tOwner = $self.owner;
		
		if (tOwner is FighterMain) {
			_owner = tOwner;
		}
		else if (tOwner is Assister) {
			_owner = tOwner.getOwner();
		}
		else if (tOwner is FighterAttacker) {
			tOwner = tOwner.getOwner();
			
			if (tOwner is FighterMain) {
				_owner = tOwner;
			}
			else if (tOwner is Assister) {
				_owner = tOwner.getOwner();
			}
		}
	}
	else if ($self is FighterAttacker) {
		tOwner = $self.getOwner();
		
		if (tOwner is FighterMain) {
			_owner = tOwner;
		}
		else if (tOwner is Assister) {
			_owner = tOwner.getOwner();
		}
	}
	
	return _owner;
}

var _target:* = null;
/**
 * 获得对手主人类引用，始终返回 FighterMain
 */
function get $target():* {
	if (_target) {
		return _target;
	}
	
	_target = $owner.getCurrentTarget();
	
	return _target as FighterMain;
}

/**
 * 获得自身名称
 */
function get $name():String {
	if (!$self) {
		return "N/A";
	}
	
	return $self.getDisplay().name;
}

/**
 * 获得双方血量差
 */
function get $hpDiff():int {
	return Math.abs($owner.hp - $target.hp);
}

//////////////////////////////////////////////////////////////////////////////////////////




//////////////////////////////////////////////////////////////////////////////////////////
// 初始化

_initialize();

//////////////////////////////////////////////////////////////////////////////////////////