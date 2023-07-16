disableSerialization;

waitUntil { !isNull findDisplay 46 }; 

private _display = findDisplay 46;
_display displayAddEventHandler ["KeyDown", {
	if (
		isNull (findDisplay 602) && {_this # 1 == 46 && {isNull(localNamespace  getVariable ['animHUD_display', displayNull])}}
	) then {
		call animHUD;
	};
}];

animHUD = {
	// обработчик отжатия клавиши
	private _display = findDisplay 46 createDisplay "RscDisplayEmpty";
	_display displayAddEventHandler ["KeyUp", {
		(localNamespace  getVariable 'animHUD_display') closeDisplay 1;
		localNamespace  setVariable ['animHUD_display', nil];
		private _display = _this # 0;
		_display displayRemoveEventHandler [_thisEvent, _thisEventHandler];
		_display displayRemoveAllEventHandlers "KeyDown";
	}];

	// обработчик открытия инвентаря
	private _invEH = localNamespace getVariable "animHUD_invEH";
	if (!isNil {_invEH}) then {
		player removeEventHandler ["InventoryOpened", _invEH];
	};
	_invEH = player addEventHandler ["InventoryOpened", {
		player removeEventHandler [_thisEvent, _thisEventHandler];
		(localNamespace  getVariable 'animHUD_display') closeDisplay 1;
		localNamespace setVariable ["animHUD_invEH", nil];
		localNamespace setVariable ["animHUD_display", player]; // player для проверки на нюль
		_invEH = player addEventHandler ["InventoryClosed", {
			player removeEventHandler [_thisEvent, _thisEventHandler];
			localNamespace setVariable ["animHUD_display", displayNull];
		}];
	}];

	localNamespace setVariable ["animHUD_invEH", _invEH];
	localNamespace setVariable ["animHUD_display", _display];
	localNamespace setVariable ["animHUD_items", [[],[],[]]];

	// центральный элемент
	[0] call animHUD_createItem;
	_items = localNamespace getVariable "animHUD_items";
	
	// остальные элементы
	_ctrl = _items # 0 # 0 # 0;
	for "_i" from 1 to 4 do {
		[1] call animHUD_createItem;
	};
	_ctrl = _items # 1 # 0 # 0;
	for "_i" from 1 to 36 do {
		[2] call animHUD_createItem;
	};

	[] spawn animHUD_setItemsData; // функционал элементов (кто надо становится видимым, другие скрываются)
};

animHUD_createItem = {
	params ["_lvl"];
	private ["_ctrlWidth", "_ctrlHeigth", "_ctrlParentHeigth", "_ctrlX", "_ctrlY", "_ctrlPicture", "_ctrlAngle"];
	private ["_ctrl2Width", "_ctrl2Heigth", "_ctrl2X", "_ctrl2Y", "_ctrl2Text"];

	private _display = localNamespace getVariable "animHUD_display";
	private _items = localNamespace getVariable "animHUD_items";
	private _ctrl = _display ctrlCreate ["RscPicture", -1];
	private _ctrl2 = _display ctrlCreate ["RscStructuredText", -1];

	call {
		// центральный элемент
		if (_lvl == 0) exitWith {
			_ctrlWidth = 0.1 * safeZoneW;
			_ctrlHeigth = _ctrlWidth * (safeZoneW/safeZoneH);
			_ctrlParentHeigth = 0;
			_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
			_ctrlY = (safeZoneH -  _ctrlHeigth) / 2 + safeZoneY;
			_ctrlPicture = "lvl1.paa";

			_ctrl2Width = _ctrlWidth;
			_ctrl2Heigth = _ctrlHeigth;
			_ctrl2X =_ctrlX;
			_ctrl2Y = _ctrlY;

			private _ctrlHeightInSFH = _ctrlHeigth / safeZoneH;
			private _fontHeightInSFH = 1 / 30;
			private _padding = (_ctrlHeightInSFH / _fontHeightInSFH) / 2 - 1;
			_ctrl2 ctrlSetFontHeight (safeZoneH * _fontHeightInSFH);
			_ctrl2Text = parseText (format ["<t size='%1'>&#160;</t><br/><t size='1' align='center'> STOP  ANIMATION</t>", _padding]);
		};
		
		// подкатегории анимок
		if (_lvl == 1) exitWith {
			_ctrlWidth = 0.16 * safeZoneW;
			_ctrlHeigth = _ctrlWidth * (4/3);
			_ctrlPicture = "lvl2.paa";

			// поворот
			private _items = localNamespace getVariable "animHUD_items";
			private _index = count (_items # 1);
			call {
				if (_index == 0) exitWith {
					_ctrlX = (safeZoneH - _ctrlHeigth) / 2 + safeZoneY;
					_ctrlY = (safeZoneH - _ctrlHeigth) / 2 + safeZoneY;
					_ctrlAngle = 270;

					_ctrl2X =_ctrlX;
					_ctrl2Y = _ctrlY + (_ctrlHeigth * 0.2);
					_ctrl2Text = "1";
				};
				if (_index == 1) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
					_ctrlY = (safeZoneH - _ctrlHeigth) / 2 + safeZoneY;
					_ctrlAngle = 0;

					_ctrl2X =_ctrlX;
					_ctrl2Y = _ctrlY + (_ctrlHeigth * 0.15);
					_ctrl2Text = "2";
				};
				if (_index == 2) exitWith {
					_ctrlX = (safeZoneH - _ctrlHeigth) / 2 + safeZoneY;
					_ctrlY = (safeZoneH - _ctrlHeigth) / 2 + safeZoneY;
					_ctrlAngle = 90;

					_ctrl2X =_ctrlX;
					_ctrl2Y = _ctrlY + (_ctrlHeigth * 0.2);
					_ctrl2Text = "3";
				};
				if (_index == 3) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
					_ctrlY = (safeZoneH - _ctrlHeigth) / 2 + safeZoneY;
					_ctrlAngle = 180;

					_ctrl2X =_ctrlX;
					_ctrl2Y = _ctrlY + (_ctrlHeigth * 0.25);
					_ctrl2Text = "";
				};
			};
			_ctrl2Width = _ctrlWidth;
			_ctrl2Heigth = _ctrlHeigth;

			private _ctrlHeightInSFH = _ctrl2Heigth / safeZoneH;
			private _fontHeightInSFH = 1 / 30;
			private _padding = (_ctrlHeightInSFH / _fontHeightInSFH) / 2 - 2;
			_ctrl2 ctrlSetFontHeight (safeZoneH * _fontHeightInSFH);
			_ctrl2Text = parseText (format ["<t size='%2'>&#160;</t><br/><t size='1' align='center'>%1</t>", _ctrl2Text, _padding]);
		};
		// элементы самих анимок
		if (_lvl == 2) exitWith {
			_ctrlWidth = 0.071 * safeZoneW;
			_ctrlHeigth = _ctrlWidth * (4/3);
			_ctrlPicture = "lvl3.paa";

			// поворот
			private _items = localNamespace getVariable "animHUD_items";
			private _index = count (_items # 2);
			call {
				// 1
				if (_index in [0,12,24]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
					_ctrlY = (safeZoneH -  _ctrlHeigth) / 2 + safeZoneY;
					_ctrlAngle = 270;
				};
				if (_index in [1,13,25]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
					_ctrlY = (safeZoneH -  _ctrlHeigth) / 2 + safeZoneY;
					_ctrlAngle = 292.5;
				};
				if (_index in [2,14,26]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
					_ctrlY = (safeZoneH -  _ctrlHeigth) / 2 + safeZoneY;
					_ctrlAngle = 314;
				};
				if (_index in [3,15,27]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
					_ctrlY = (safeZoneH -  _ctrlHeigth) / 2 + safeZoneY;
					_ctrlAngle = 336.5;
				};
				// 2
				if (_index in [4,16,28]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
					_ctrlY = (safeZoneH -  _ctrlHeigth) / 2 + safeZoneY;
					_ctrlAngle = -1;
				};
				if (_index in [5,17,29]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
					_ctrlY = (safeZoneH -  _ctrlHeigth) / 2 + safeZoneY;
					_ctrlAngle = 21.5;
				};
				if (_index in [6,18,30]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
					_ctrlY = (safeZoneH -  _ctrlHeigth) / 2 + safeZoneY;
					_ctrlAngle = 45;
				};
				if (_index in [7,19,31]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
					_ctrlY = (safeZoneH -  _ctrlHeigth) / 2 + safeZoneY;
					_ctrlAngle = 67.5;
				};
				// 3
				if (_index in [8,20,32]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
					_ctrlY = (safeZoneH - _ctrlHeigth) / 2 + safeZoneY;
					_ctrlAngle = 89;
				};
				if (_index in [9,21,33]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
					_ctrlY = (safeZoneH - _ctrlHeigth) / 2 + safeZoneY;
					_ctrlAngle = 111.5;
				};
				if (_index in [10,22,34]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
					_ctrlY = (safeZoneH - _ctrlHeigth) / 2 + safeZoneY;
					_ctrlAngle = 134;
				};
				if (_index in [11,23,35]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX ;
					_ctrlY = (safeZoneH - _ctrlHeigth) / 2 + safeZoneY;
					_ctrlAngle = 156.5;
				};
			};
			
			_ctrl2Width = _ctrlWidth;
			_ctrl2Heigth = _ctrlHeigth;
			_ctrl2X = _ctrlX;
			_ctrl2Y = _ctrlY;

			// текст почти по центру
			private _ctrlHeightInSFH = _ctrl2Heigth / safeZoneH;
			private _fontHeightInSFH = 1 / 30;
			private _padding = (_ctrlHeightInSFH / _fontHeightInSFH) - 2;

			_ctrl2 ctrlSetFontHeight (safeZoneH * _fontHeightInSFH);
			_ctrl2Text = ["", _index + 1] select (_index < 32);
			_ctrl2Text = parseText (format ["<t size='%2'>&#160;</t><br/><t size='1' align='center'>%1</t>", _ctrl2Text, _padding]);
		};
	};

	// сам элемент
	_ctrl ctrlSetPosition [_ctrlX, _ctrlY, _ctrlWidth, _ctrlHeigth];
	_ctrl ctrlSetText _ctrlPicture;
	_ctrl ctrlSetFade 0.3;
	_ctrl ctrlCommit 0;
	_ctrl ctrlSetAngle [_ctrlAngle, 0.5, 0.5];

	// текст внутри элемента
	_ctrl2 ctrlSetPosition [_ctrl2X, _ctrl2Y, _ctrl2Width, _ctrl2Heigth];
	_ctrl2 ctrlSetStructuredText _ctrl2Text;
	_ctrl2 ctrlSetFont "PuristaSemibold";
	_ctrl2 ctrlCommit 0;
	_ctrl2 ctrlSetAngle [_ctrlAngle, 0.5, 0.5];

	// скрывание элементов
	_ctrl ctrlEnable false;
	_ctrl2 ctrlEnable false;
	_ctrl ctrlShow false;
	_ctrl2 ctrlShow false;

	// добавление элементов в общий массив
	private _items = localNamespace getVariable ["animHUD_items", [[],[],[]]];
	(_items # _lvl) pushBack [_ctrl, _ctrl2];
	localNamespace setVariable ["animHUD_items", _items];
};

animHUD_setItemsData = {
	private _items = localNamespace getVariable "animHUD_items";
	private _ctrl = _items # 0 # 0 # 0;
	private _ctrlData = _items # 0 # 0 # 1;

	// показ центрального элемента
	_ctrl ctrlShow true;
	_ctrlData ctrlShow true;

	// показ элементов подкатегорий
	{
		private _ctrl2 = _x # 0;
		private _ctrl2Data = _x # 1;

		_ctrl2 ctrlShow true;
		_ctrl2Data ctrlShow true;
	} forEach _items # 1;

	// обработка нажатия на элементы
	private _display = localNamespace getVariable "animHUD_display";
	_display displayAddEventHandler ["mouseButtonDown", {
		if (_this # 1 == 0) then { // ЛКМ
			[_this] spawn {
				private _index = call animHUD_getNearestItemIndex;
				private _items = localNamespace getVariable "animHUD_items";

				// центральный элемент
				if (_index == 0) exitWith {
					if (localNamespace getVariable ["animHUD_animRun", false]) then {
						[] spawn { // выход из ступора
							player action ["SWITCHWEAPON",player,player,0];
							player switchMove "Netu";
							player setAnimSpeedCoef 1;

							// удаление EH инвентаря
							private _keyEH = localNamespace getVariable ["animHUD_EH", -1];
							if (str _keyEH != "-1") then {
								(findDisplay 46) displayRemoveEventHandler ["keyDown", _keyEH];
							};

							localNamespace setVariable ["animHUD_animRun", false];

							private _items = localNamespace getVariable "animHUD_items";
							(_items # 0 # 0 # 0) ctrlSetText "lvl1-selected.paa"; // выделение пока надо
							sleep 0.2;
							(_items # 0 # 0 # 0) ctrlSetText "lvl1.paa"; // уже не надо
						};
					};

					// скрытие внешнего слоя
					{
						(_x # 0) ctrlShow false;
						(_x # 1) ctrlShow false;
					} forEach _items # 2;

					{ (_x # 0) ctrlSetText "lvl2.paa" } forEach (_items # 1); // снятие выделения
				};
				
				// элементы подкатегорий
				if (_index < 4) exitWith {
					_index = _index - 1;

					{ (_x # 0) ctrlSetText "lvl2.paa"; } forEach (_items # 1); // снятие выделения
					(_items # 1 # _index # 0) ctrlSetText "lvl2-selected.paa"; // выделение выбранной

					// скрытие всех элементов анимок
					{
						private _ctrl3 = _x # 0;
						private _ctrl3Data = _x # 1;

						_ctrl3 ctrlShow false;
						_ctrl3Data ctrlShow false;
					} forEach _items # 2;

					// показ анимок данной подкатегории
					{
						private _ctrl3 = _x # 0;
						private _ctrl3Data = _x # 1;

						_ctrl3 ctrlShow true;
						_ctrl3Data ctrlShow true;

						[_ctrl3Data, (_index * 12 + _forEachIndex)] call animHUD_setItemAnim;
					} forEach ((_items # 2) select [_index * 12, 12]);
				};

				// элементы самих анимок
				private "_section";
				{
					if (ctrlText (_x # 0) == "lvl2-selected.paa") then {
						_section = _forEachIndex;
					};
				} forEach (_items # 1);

				if (!isNil {_section} && {!(localNamespace getVariable ["animHUD_animRun", false])}) then {
					_index = _section * 12 + (_index - 5);
					if (_index < 32) then {
						private _anim = (localNamespace getVariable "animHUD_animsData") # _index # 1;
						_index spawn {
							params ["_index"];
							private _items = localNamespace getVariable "animHUD_items";
							(_items # 2 # _index # 0) ctrlSetText "lvl3-selected.paa"; // выделение пока надо
							sleep 0.2;
							{ (_x # 0) ctrlSetText "lvl3.paa"; } forEach (_items # 2); // уже не надо
						};

						private _keyEH = (findDisplay 46) displayAddEventHandler ["KeyDown", {
							_key = _this select 1;
							["MoveForward", "MoveBack", "TurnLeft", "TurnRight", "GetOver", "SitDown", "Stand", "Prone", "MoveUp", "MoveDown", "EvasiveLeft", "EvasiveRight"] findIf {_key in (actionKeys _x)} >= 0;
						}];
						localNamespace setVariable ["animHUD_EH", _keyEH];

						private _ctrl = _items # 2 # _index;
						localNamespace setVariable ["animHUD_animRun", true];
						[_ctrl] spawn _anim;
						sleep 1;

						waitUntil { sleep 1; animationState player in [
							"amovpercmstpsraswrfldnon",
							"amovpercmstpslowwrfldnon",
							"amovpercmstpsnonwnondnon",
							"amovpknlmstpsraswrfldnon",
							"amovpercmstpsraswlnrdnon_turnl"
						]};
						(findDisplay 46) displayRemoveEventHandler ["keyDown", _keyEH];
						localNamespace setVariable ["animHUD_animRun", false];
					};
				};
			};
		};
	}];
};

animHUD_getNearestItemIndex = { // функция получения индекса ближайшего к мыши элемента на определённом уровне
	private _items = localNamespace getVariable "animHUD_items";
	private _distances = [];
	{
		{
			_ctrl = _x # 0;
			_ctrlPos = ctrlPosition _ctrl;
			_ctrlPos = [_ctrlPos # 0, _ctrlPos # 1] vectorAdd [(_ctrlPos # 2) / 2, (_ctrlPos # 3) / 2];
			_distance = _ctrlPos vectorDistance getMousePosition;
			_distances pushBack _distance;
		} foreach _x;
	} foreach _items;
	_itemIndex = _distances find (selectMin _distances);
	_itemIndex;
};

animHUD_doWithoutWeapons = { // функция выполнения кода с удалением оружия у игрока
	params ["_code", "_args"];
	// сохранение данных
	private _weapons = weaponsItems player;
	private _magazines = magazinesAmmo player;
	private _currentWeaponState = player weaponState (currentWeapon player);
	
	{ player removeMagazineGlobal (_x # 0) } forEach _magazines; // удаление магазинов
	{ player removeWeapon (_x # 0) } forEach _weapons; // удаление оружия
	
	player switchAction "AmovPercMstpSnonWnonDnon"; // выход из ступора

	private _handle = [_args] spawn _code; // выплонение кода
	waitUntil {sleep 1; scriptDone _handle || {!(localNamespace getVariable "animHUD_animRun")}};

	player switchAction "AmovPercMstpSnonWnonDnon";// выход из ступора
	
	{ player addWeapon (_x # 0) } forEach _weapons; // добавление оружия
	{ player addMagazine (_x # 0) } forEach _magazines; // добавление магазинов

	// удаление стоковых обвесов
	removeAllPrimaryWeaponItems player; 
	removeAllSecondaryWeaponItems player;
	removeAllHandgunItems player;
	
	{ player addWeaponItem [_x, _x # 4 # 0, true] } forEach _weapons; // добавление магазинов оружию
	
	{ // установка обвесов оружию
		private _weapon = _x # 0;
		private _magazine = _x # 4;
		if (count _magazine > 0) then {
			player setAmmo [_weapon, _magazine # 1];
		};
		{
			player addWeaponItem [_weapon, _x, true];
		} forEach _x;
	} forEach _weapons;
	
	player selectWeapon (_currentWeaponState select [0, 3]); // выбор сохраннёного оружия
};

animHUD_setItemAnim = {
	params ["_ctrl3Data", "_index"];
	
	localNamespace setVariable ["animHUD_animsData", [
		// 1-4
		["Приветствие", {
			player action ["SWITCHWEAPON",player,player,-1];
			sleep 2;
			player switchMove "Acts_JetsMarshallingClear_in";
			sleep 3;
			player action ["SWITCHWEAPON",player,player,0];
		}],
		["Остановить", {
			player playMove "Acts_Ambient_Defensive";
		}],
		["Отказаться", {
			player playMove "Acts_Ambient_Disagreeing";
		}],
		["Птичка", {
			player action ["SWITCHWEAPON",player,player,-1];
			sleep 0.1;
			player switchMove "Acts_JetsMarshallingSlow_in";
			sleep 3;
			player action ["SWITCHWEAPON",player,player,0];
		}],
		// 4-8
		["Танец 1", {
			player action ["SWITCHWEAPON",player,player,-1];
			sleep 0.1;
			player switchMove "Acts_Dance_01";
		}],
		["Танец 2", {
			player action ["SWITCHWEAPON",player,player,-1];
			sleep 0.1;
			player switchMove "Acts_Dance_02";
		}],
		["Выпить", {
			player action ["SWITCHWEAPON",player,player,-1];
			sleep 2;
			player switchMove "Acts_JetsOfficerSpilling";
			sleep 4;
			player switchMove "AmovPercMstpSnonWnonDnon";
			player playMoveNow "AmovPercMstpSnonWnonDnon";
			player action ["SWITCHWEAPON",player,player,0];
		}],
		["Руки за голову", {
			player action ["SWITCHWEAPON",player,player,-1];
			sleep 0.1;
			player switchMove "AmovPercMstpSnonWnonDnon_AmovPercMstpSsurWnonDnon";
		}],
		// 9-12
		["Отжимания", {
			player playMove "AmovPercMstpSnonWnonDnon_exercisePushup";
		}],
		["Приседания", {
			player playMove "AmovPercMstpSnonWnonDnon_exercisekneeBendA";
		}],
		["Карате", {
			[{
				player playMove "AmovPercMstpSnonWnonDnon_exerciseKata";
				sleep 33.333;
			},[]] spawn animHUD_doWithoutWeapons;
		}],
		["Усталось", {
			player playMove "Acts_Ambient_Gestures_Tired"
		}],
		// 13-16
		["Укрыться сидя", {
			[{
				player switchMove "ApanPercMstpSnonWnonDnon_ApanPknlMstpSnonWnonDnon";
				sleep 120;
			},[]] spawn animHUD_doWithoutWeapons
		}],
		["Укрыться лёжа", {
			[{
				player switchMove "ApanPercMstpSnonWnonDnon_ApanPpneMstpSnonWnonDnon";
				sleep 120;
			},[]] spawn animHUD_doWithoutWeapons
		}],
		["Завязать шнурки", {
			player playMove "Acts_Ambient_Shoelaces";
		}],
		["Подобрать кое-что", {
			player playMove "Acts_Ambient_Picking_Up";
		}],
		// 17-20
		["Незнание", {
			player playMove "Acts_Ambient_Approximate";
		}],
		["Facepalm", {
			player playMove "Acts_Ambient_Facepalm_2";
		}],
		["Руки вверх", {
			player switchMove "Acts_JetsMarshallingStop_in";
			sleep 1;
			private _EH = addMissionEventHandler ["EachFrame", {  
				player switchMove "Acts_JetsMarshallingStop_loop";
			}];
			waitUntil {sleep 0.2; !(localNamespace getVariable "animHUD_animRun")};
			removeMissionEventHandler ["EachFrame", _EH];
			player switchMove "Acts_JetsMarshallingStop_out";
		}],
		["Крест руками", {
			player switchMove "Acts_JetsMarshallingEmergencyStop_in";
		}],
		// 21-24
		["Зевнуть", {
			player playMove "Acts_Ambient_Gestures_Yawn";
		}],
		["Чихнуть", {
			player playMove "Acts_Ambient_Gestures_Sneeze";
		}],
		["Потереть нос", {
			player playMove "Acts_Ambient_Cleaning_Nose";
		}],
		["Справлять нужду", {
			player switchMove "Acts_AidlPercMstpSlowWrflDnon_pissing";
		}],
		// 25-28
		["Вперёд", {
			player playMove "Acts_Pointing_Front";
		}],
		["Направо", {
			player playMove "Acts_Pointing_Right";
		}],
		["Налево", {
			player playMove "Acts_Pointing_Left";
		}],
		["Назад", {
			player playMove "Acts_Pointing_Back";
		}],
		// 29-32
		["Вверх", {
			player playMove "Acts_Pointing_Up";
		}],
		["Вниз", {
			player playMove "Acts_Pointing_Down";
		}],
		["Ремонт колеса", {
			player switchMove "Acts_carFixingWheel";
		}],
		["Смирно", {
			player action ["SWITCHWEAPON",player,player,-1];
			sleep 0.1;
			player switchMove "HubTemplateU";
			player setAnimSpeedCoef 0.125;
		}]
	]];

	if (_index < 32) then {
		_ctrl3Data ctrlSetTooltip ((localNamespace getVariable "animHUD_animsData") # _index # 0);
	};
};