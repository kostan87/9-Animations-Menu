disableSerialization;

waitUntil { !isNull findDisplay 46 }; 

private _display = findDisplay 46;
_display displayAddEventHandler ["KeyDown", {
	if (
		isNull (findDisplay 602) && 
		{_this # 1 == 46 && 
		{isNull (localNamespace  getVariable ['animGUI_display', displayNull])}} 
	) then {
		call animGUI;
	};
}];

animGUI = {
	// обработчик отжатия клавиши
	private _display = findDisplay 46 createDisplay "RscDisplayEmpty";
	_display displayAddEventHandler ["KeyUp", {
		(localNamespace  getVariable 'animGUI_display') closeDisplay 1;
		localNamespace  setVariable ['animGUI_display', nil];
		private _display = _this # 0;
		_display displayRemoveEventHandler [_thisEvent, _thisEventHandler];
		_display displayRemoveAllEventHandlers "KeyDown";
	}];

	// обработчик открытия инвентаря
	private _invEH = localNamespace getVariable "animGUI_invEH";
	if (!isNil {_invEH}) then {
		player removeEventHandler ["InventoryOpened", _invEH];
	};
	_invEH = player addEventHandler ["InventoryOpened", {
		player removeEventHandler [_thisEvent, _thisEventHandler];
		(localNamespace  getVariable 'animGUI_display') closeDisplay 1;
		localNamespace setVariable ["animGUI_invEH", nil];
		localNamespace setVariable ["animGUI_display", player]; // player для проверки на нюль
		_invEH = player addEventHandler ["InventoryClosed", {
			player removeEventHandler [_thisEvent, _thisEventHandler];
			localNamespace setVariable ["animGUI_display", displayNull];
		}];
	}];

	localNamespace setVariable ["animGUI_invEH", _invEH];
	localNamespace setVariable ["animGUI_display", _display];
	localNamespace setVariable ["animGUI_items", [[],[],[]]];
	
	// чтобы фон не перекрывал рабочие элементы - он создается первым отдельно

	// создание фона
	// центральный элемент
	[0, 0, 1] call animGUI_createItem;
	// категории
	for "_i" from 1 to 4 do {
		[1, _i - 1, 1] call animGUI_createItem;
	};
	// анимки
	for "_i" from 1 to 36 do {
		[2, _i - 1, 1] call animGUI_createItem;
	};

	// создание текста
	// центральный элемент
	[0, 0, 2] call animGUI_createItem;
	// категории
	for "_i" from 1 to 4 do {
		[1, _i - 1, 2] call animGUI_createItem;
	};
	// анимки
	for "_i" from 1 to 36 do {
		[2, _i - 1, 2] call animGUI_createItem;
	};
	
	[] spawn animGUI_setItemsData; // функционал элементов (кто надо становится видимым, другие скрываются)
};


animGUI_createItem = { // функция создания элемента меню анимок
	// lvl: 1 - центральная кнопка, 2 - подкатегории, 3 - анимки | elemID: 1 - фон, 2 - текст
	params ["_lvl", "_index", "_elemID"];

	private ["_ctrlWidth", "_ctrlHeight", "_ctrlX", "_ctrlY", "_ctrlText", "_ctrlAngle"];

	private _display = localNamespace getVariable "animGUI_display";
	private _ctrl_type = ["RscPicture", "RscStructuredText"] select (_elemID - 1);
	private _ctrl = _display ctrlCreate [_ctrl_type, -1];

	// формула для ctlrY = (safeZoneH - (Выс.Элем.1 + Выс.Элем.2 + ... + Выс.Элем.N * Коэфф.)) / 2 + safeZoneY
	// почему-то для всех разрешений сработала только она
	// высота элементов для формулы
	private _ctrlHeight_lvl1 = (0.105 * safeZoneH) * ((getResolution # 0) / (getResolution # 1));
	private _ctrlHeight_lvl2 = (0.15 * safeZoneH) * ((getResolution # 0) / (getResolution # 1));
	private _ctrlHeight_lvl3 = (0.0962 * safeZoneH) * ((getResolution # 0) / (getResolution # 1));

	switch (_lvl) do {
		case 0: { // центральный элемент
			_ctrlWidth = 0.105 * safeZoneW;
			_ctrlHeight = _ctrlHeight_lvl1;
			_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
			_ctrlY = (safeZoneH - _ctrlHeight) / 2 + safeZoneY;

			if (_elemID == 1) then {
				_ctrlText = "lvl1.paa";
			} else {
				// текст по центру для разных разрешений
				private _ctrlHeight_in_safeZoneH = _ctrlHeight / safeZoneH;
				private _fontHeight_in_safeZoneH = 1 / 30;
				private _padding = (_ctrlHeight_in_safeZoneH / _fontHeight_in_safeZoneH) / 2 - 1;
				_ctrl ctrlSetFontHeight (safeZoneH * _fontHeight_in_safeZoneH);

				_ctrlText = "STOP ANIMATION";
				_ctrlText = format ["<t size='%2'>&#160;</t><br/><t size='1' align='center'>%1</t>", _ctrlText, _padding];
			};			
		};
		case 1: { // элементы категорий
			_ctrlWidth = 0.15 * safeZoneW;
			_ctrlHeight = _ctrlHeight_lvl2;

			switch (_index) do {
				case 0: {
					_ctrlX = ((safeZoneW - _ctrlWidth) / 2) * 0.833 + safeZoneX;
					_ctrlY = (safeZoneH - _ctrlHeight) / 2 + safeZoneY;
					_ctrlAngle = 270;
				};
				case 1: {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
					_ctrlY = (safeZoneH - (_ctrlHeight + _ctrlHeight_lvl1 * 1.355)) / 2 + safeZoneY;
					_ctrlAngle = 0;
				};
				case 2: {
					_ctrlX = ((safeZoneW - _ctrlWidth) / 2) * 1.168 + safeZoneX;
					_ctrlY = (safeZoneH - _ctrlHeight) / 2 + safeZoneY;
					_ctrlAngle = 90;
				};
				case 3: {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
					_ctrlY = (safeZoneH + (_ctrlHeight + _ctrlHeight_lvl1 * -1.5)) / 2 + safeZoneY;
					_ctrlAngle = 180;
				};
			};

			private "_padding";
			if (_elemID == 1) then {
				_ctrlText = "lvl2.paa";
			} else {
				if (_index in [0,2]) then {
					_ctrlWidth = _ctrlWidth / 2;
					_ctrlX = _ctrlX + _ctrlWidth / 2;
					_padding = safeZoneH * 2.7;
				} else {
					_ctrlHeight = _ctrlHeight / 2;
					_ctrlY = _ctrlY + _ctrlHeight / 2;
					_padding = safeZoneH;
				};


				_ctrlText = ["1", "2", "3", ""] select _index;
				_ctrlText = format ["<t size='%2'>&#160;</t><br/><t size='1' align='center'>%1</t>", _ctrlText, _padding];
			};
		};
		case 2: { // элементы анимаций
			_ctrlWidth = 0.0962 * safeZoneW;
			_ctrlHeight = _ctrlHeight_lvl3;

			call {
				// 1 - 4
				if (_index in [0,12,24]) exitWith { // 1
					_ctrlX = ((safeZoneW - _ctrlWidth) / 2) * 0.75 + safeZoneX;
					_ctrlY = (safeZoneH - (_ctrlHeight + _ctrlHeight_lvl1 + _ctrlHeight_lvl2 * -1.74)) / 2 + safeZoneY;
					_ctrlAngle = 270;
				};
				if (_index in [1,13,25]) exitWith { // 2
					_ctrlX = ((safeZoneW - _ctrlWidth) / 2) * 0.703 + safeZoneX;
					_ctrlY = (safeZoneH - (_ctrlHeight + _ctrlHeight_lvl1 + _ctrlHeight_lvl2 * -1.079)) / 2 + safeZoneY;
					_ctrlAngle = 292.5;
				};
				if (_index in [2,14,26]) exitWith { // 3
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 * 0.701 + safeZoneX;
					_ctrlY = (safeZoneH - (_ctrlHeight + _ctrlHeight_lvl1 + _ctrlHeight_lvl2 * -0.364)) / 2 + safeZoneY;
					_ctrlAngle = 315;
				};
				if (_index in [3,15,27]) exitWith { // 4
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 * 0.745 + safeZoneX;
					_ctrlY = (safeZoneH - (_ctrlHeight + _ctrlHeight_lvl1 + _ctrlHeight_lvl2 * 0.3)) / 2 + safeZoneY;
					_ctrlAngle = 337.5;
				};
				// 5 - 8
				if (_index in [4,16,28]) exitWith { // 5
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 * 0.828 + safeZoneX;
					_ctrlY = (safeZoneH - (_ctrlHeight + _ctrlHeight_lvl1 + _ctrlHeight_lvl2 * 0.807)) / 2 + safeZoneY;
					_ctrlAngle = 0;
				};
				if (_index in [5,17,29]) exitWith { // 6
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 * 0.937 + safeZoneX;
					_ctrlY = (safeZoneH - (_ctrlHeight + _ctrlHeight_lvl1 + _ctrlHeight_lvl2 * 1.093)) / 2 + safeZoneY;
					_ctrlAngle = 22.5;
				};
				if (_index in [6,18,30]) exitWith { // 7
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 * 1.056 + safeZoneX;
					_ctrlY = (safeZoneH - (_ctrlHeight + _ctrlHeight_lvl1 + _ctrlHeight_lvl2 * 1.102)) / 2 + safeZoneY;
					_ctrlAngle = 45;
				};
				if (_index in [7,19,31]) exitWith { // 8
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 * 1.165 + safeZoneX;
					_ctrlY = (safeZoneH - (_ctrlHeight + _ctrlHeight_lvl1 + _ctrlHeight_lvl2 * 0.832)) / 2 + safeZoneY;
					_ctrlAngle = 67.5;
				};
				// 9 - 12
				if (_index in [8,20,32]) exitWith { // 9
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 * 1.251 + safeZoneX;
					_ctrlY = (safeZoneH - (_ctrlHeight + _ctrlHeight_lvl1 + _ctrlHeight_lvl2 * 0.335)) / 2 + safeZoneY;
					_ctrlAngle = 90;
				};
				if (_index in [9,21,33]) exitWith { // 10
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 * 1.298 + safeZoneX;
					_ctrlY = (safeZoneH - (_ctrlHeight + _ctrlHeight_lvl1 + _ctrlHeight_lvl2 * -0.321)) / 2 + safeZoneY;
					_ctrlAngle = 112.5;
				};
				if (_index in [10,22,34]) exitWith { // 11
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 * 1.3 + safeZoneX;
					_ctrlY = (safeZoneH - (_ctrlHeight + _ctrlHeight_lvl1 + _ctrlHeight_lvl2 * -1.026)) / 2 + safeZoneY;
					_ctrlAngle = 135;
				};
				if (_index in [11,23,35]) exitWith { // 12
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 * 1.256 + safeZoneX;
					_ctrlY = (safeZoneH - (_ctrlHeight + _ctrlHeight_lvl1 + _ctrlHeight_lvl2 * -1.694)) / 2 + safeZoneY;
					_ctrlAngle = 157.5;
				};
			};

			if (_elemID == 1) then {
				_ctrlText = "lvl3.paa";
			} else {
				_ctrlWidth = _ctrlWidth / 2;
				_ctrlHeight = _ctrlHeight / 2;
				_ctrlX = _ctrlX + _ctrlWidth / 2;
				_ctrlY = _ctrlY + _ctrlHeight / 2;

				private _padding = safeZoneH * 0.5;
				_ctrlText = ["", str (_index + 1)] select (_index < 32);
				_ctrlText = format ["<t size='%2'>&#160;</t><br/><t size='1' align='center'>%1</t>", _ctrlText, _padding];
			
				_ctrl ctrlSetTooltip str _index;
			};
		};
	};

	_ctrl ctrlSetPosition [_ctrlX, _ctrlY, _ctrlWidth, _ctrlHeight];
	_ctrl ctrlCommit 0;

	if (_elemID == 1) then {
		_ctrl ctrlSetText _ctrlText;
		_ctrl ctrlSetFade 0.3;
		_ctrl ctrlSetAngle [_ctrlAngle, 0.5, 0.5];
		_ctrl ctrlCommit 0;
	} else {
		_ctrl ctrlSetStructuredText parseText _ctrlText;
		_ctrl ctrlSetFont "PuristaSemibold";
	};

	// скрывание элемента
	_ctrl ctrlEnable false;
	_ctrl ctrlShow false;

	// добавление элемента в общий массив в виде массива [фон, текст]
	private _items = localNamespace getVariable ["animGUI_items", [[],[],[]]];
	if (count (_items # _lvl) < (_index + 1)) then { (_items # _lvl) set [_index, []] };
	(_items # _lvl # _index) set [(_elemID - 1), _ctrl];
	localNamespace setVariable ["animGUI_items", _items];
};

animGUI_setItemsData = {
	private _items = localNamespace getVariable "animGUI_items";
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
	private _display = localNamespace getVariable "animGUI_display";
	_display displayAddEventHandler ["mouseButtonDown", {
		if (_this # 1 == 0) then { // ЛКМ
			[_this] spawn {
				private _index = call animGUI_getNearestItemIndex;
				private _items = localNamespace getVariable "animGUI_items";

				// центральный элемент
				if (_index == 0) exitWith {
					if (localNamespace getVariable ["animGUI_animRun", false]) then {
						[] spawn { // выход из ступора
							player action ["SWITCHWEAPON",player,player,0];
							player switchMove "Netu";
							player setAnimSpeedCoef 1;

							// удаление EH инвентаря
							private _keyEH = localNamespace getVariable ["animGUI_EH", -1];
							if (str _keyEH != "-1") then {
								(findDisplay 46) displayRemoveEventHandler ["keyDown", _keyEH];
							};

							localNamespace setVariable ["animGUI_animRun", false];

							private _items = localNamespace getVariable "animGUI_items";
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

						[_ctrl3, _ctrl3Data, (_index * 12 + _forEachIndex)] call animGUI_setItemAnim;
					} forEach ((_items # 2) select [_index * 12, 12]);
				};

				// элементы самих анимок
				private "_section";
				{
					if (ctrlText (_x # 0) == "lvl2-selected.paa") then {
						_section = _forEachIndex;
					};
				} forEach (_items # 1);

				if (!isNil {_section} && {!(localNamespace getVariable ["animGUI_animRun", false])}) then {
					_index = _section * 12 + (_index - 5);
					if (_index < 32) then {
						private _anim = (localNamespace getVariable "animGUI_animsData") # _index # 1;
						_index spawn {
							params ["_index"];
							private _items = localNamespace getVariable "animGUI_items";
							(_items # 2 # _index # 0) ctrlSetText "lvl3-selected.paa"; // выделение пока надо
							sleep 0.2;
							{ (_x # 0) ctrlSetText "lvl3.paa"; } forEach (_items # 2); // уже не надо
						};

						private _keyEH = (findDisplay 46) displayAddEventHandler ["KeyDown", {
							_key = _this select 1;
							["MoveForward", "MoveBack", "TurnLeft", "TurnRight", "GetOver", "SitDown", "Stand", "Prone", "MoveUp", "MoveDown", "EvasiveLeft", "EvasiveRight"] findIf {_key in (actionKeys _x)} >= 0;
						}];
						localNamespace setVariable ["animGUI_EH", _keyEH];

						private _ctrl = _items # 2 # _index;
						localNamespace setVariable ["animGUI_animRun", true];
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
						localNamespace setVariable ["animGUI_animRun", false];
					};
				};
			};
		};
	}];
};

animGUI_setItemAnim = {
	params ["_ctrl3", "_ctrl3Data", "_index"];
	
	localNamespace setVariable ["animGUI_animsData", [
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
			},[]] spawn animGUI_doWithoutWeapons;
		}],
		["Усталось", {
			player playMove "Acts_Ambient_Gestures_Tired"
		}],
		// 13-16
		["Укрыться сидя", {
			[{
				player switchMove "ApanPercMstpSnonWnonDnon_ApanPknlMstpSnonWnonDnon";
				sleep 120;
			},[]] spawn animGUI_doWithoutWeapons
		}],
		["Укрыться лёжа", {
			[{
				player switchMove "ApanPercMstpSnonWnonDnon_ApanPpneMstpSnonWnonDnon";
				sleep 120;
			},[]] spawn animGUI_doWithoutWeapons
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
			waitUntil {sleep 0.2; !(localNamespace getVariable "animGUI_animRun")};
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
		_ctrl3Data ctrlSetTooltip ((localNamespace getVariable "animGUI_animsData") # _index # 0);
	};
};

animGUI_getNearestItemIndex = { // функция получения индекса ближайшего к мыши элемента на определённом уровне
	private _items = localNamespace getVariable "animGUI_items";
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

animGUI_doWithoutWeapons = { // функция выполнения кода с удалением оружия у игрока
	params ["_code", "_args"];
	// сохранение данных
	private _weapons = weaponsItems player;
	private _magazines = magazinesAmmo player;
	private _currentWeaponState = player weaponState (currentWeapon player);
	
	{ player removeMagazineGlobal (_x # 0) } forEach _magazines; // удаление магазинов
	{ player removeWeapon (_x # 0) } forEach _weapons; // удаление оружия
	
	player switchAction "AmovPercMstpSnonWnonDnon"; // выход из ступора

	private _handle = [_args] spawn _code; // выплонение кода
	waitUntil {sleep 1; scriptDone _handle || {!(localNamespace getVariable "animGUI_animRun")}};

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