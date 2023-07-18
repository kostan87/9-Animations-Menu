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
	
	// создание фона
	// центральный элемент
	[0, 0, 1] call animGUI_createItem;
	// категории
	for "_i" from 1 to 4 do {
		[1, _i - 1, 1] call animGUI_createItem;
	};
	// анимки
	for "_i" from 1 to 12 do {
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
	for "_i" from 1 to 12 do {
		[2, _i - 1, 2] call animGUI_createItem;
	};
	
	//[] spawn animGUI_setItemsData; // функционал элементов (кто надо становится видимым, другие скрываются)
};


animGUI_createItem = { // функция создания элемента меню анимок
	// lvl: 1 - центральная кнопка, 2 - подкатегории, 3 - анимки | elemID: 1 - фон, 2 - текст
	params ["_lvl", "_index", "_elemID"];

	private ["_ctrlWidth", "_ctrlHeigth", "_ctrlX", "_ctrlY", "_ctrlText", "_ctrlAngle"];

	private _display = localNamespace getVariable "animGUI_display";
	private _ctrl_type = ["RscPicture", "RscStructuredText"] select (_elemID - 1);
	private _ctrl = _display ctrlCreate [_ctrl_type, -1];

	switch (_lvl) do {
		case 0: { // центральный элемент
			_ctrlWidth = 0.105 * safeZoneW;
			_ctrlHeigth = (0.105 * safeZoneH) * (getResolution # 4);
			_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
			_ctrlY = (safeZoneH -  _ctrlHeigth) / 2 + safeZoneY;

			if (_elemID == 1) then {
				_ctrlText = "lvl1.paa";
			} else {
				// текст по центру для разных разрешений
				private _ctrlHeight_in_safeZoneH = _ctrlHeigth / safeZoneH;
				private _fontHeight_in_safeZoneH = 1 / 30;
				private _padding = (_ctrlHeight_in_safeZoneH / _fontHeight_in_safeZoneH) / 2 - 1;
				_ctrl ctrlSetFontHeight (safeZoneH * _fontHeight_in_safeZoneH);

				_ctrlText = "STOP ANIMATION";
				_ctrlText = format ["<t size='%2'>&#160;</t><br/><t size='1' align='center'>%1</t>", _ctrlText, _padding];
			};			
		};
		case 1: { // элементы категорий
			_ctrlWidth = 0.15 * safeZoneW;
			_ctrlHeigth = (0.15 * safeZoneH) * (getResolution # 4);

			switch (_index) do {
				case 0: {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX * 1.445;
					_ctrlY = (safeZoneH - _ctrlHeigth) / 2 + safeZoneY;
					_ctrlAngle = 270;
				};
				case 1: {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
					_ctrlY = (safeZoneH - _ctrlHeigth) / 2 + safeZoneY * 2.585;
					_ctrlAngle = 0;
				};
				case 2: {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX * 0.555;
					_ctrlY = (safeZoneH - _ctrlHeigth) / 2 + safeZoneY;
					_ctrlAngle = 90;
				};
				case 3: {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX;
					_ctrlY = (safeZoneH - _ctrlHeigth) / 2 + safeZoneY * -0.58;
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
					_ctrlHeigth = _ctrlHeigth / 2;
					_ctrlY = _ctrlY + _ctrlHeigth / 2;
					_padding = safeZoneH;
				};


				_ctrlText = ["1", "2", "3", ""] select _index;
				_ctrlText = format ["<t size='%2'>&#160;</t><br/><t size='1' align='center'>%1</t>", _ctrlText, _padding];
			};
		};
		case 2: { // элементы анимаций
			_ctrlWidth = 0.0962 * safeZoneW;
			_ctrlHeigth = (0.0962 * safeZoneH) * (getResolution # 4);

			call {
				// 1
				if (_index in [0,12,24]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX * 1.708;
					_ctrlY = (safeZoneH -  _ctrlHeigth) / 2 + safeZoneY * -0.74;
					_ctrlAngle = 270;
				};
				if (_index in [1,13,25]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX * 1.84;
					_ctrlY = (safeZoneH -  _ctrlHeigth) / 2 + safeZoneY * 0.36;
					_ctrlAngle = 292.5;
				};
				if (_index in [2,14,26]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX * 1.845;
					_ctrlY = (safeZoneH -  _ctrlHeigth) / 2 + safeZoneY * 1.55;
					_ctrlAngle = 315;
				};
				if (_index in [3,15,27]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX * 1.722;
					_ctrlY = (safeZoneH -  _ctrlHeigth) / 2 + safeZoneY * 2.66;
					_ctrlAngle = 337.5;
				};
				// 2
				if (_index in [4,16,28]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX * 1.487;
					_ctrlY = (safeZoneH -  _ctrlHeigth) / 2 + safeZoneY * 3.51;
					_ctrlAngle = 0;
				};
				if (_index in [5,17,29]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX * 1.18;
					_ctrlY = (safeZoneH -  _ctrlHeigth) / 2 + safeZoneY * 3.98;
					_ctrlAngle = 22.5;
				};
				if (_index in [6,18,30]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX * 0.845;
					_ctrlY = (safeZoneH -  _ctrlHeigth) / 2 + safeZoneY * 4;
					_ctrlAngle = 45;
				};
				if (_index in [7,19,31]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX * 0.535;
					_ctrlY = (safeZoneH -  _ctrlHeigth) / 2 + safeZoneY * 3.56;
					_ctrlAngle = 67.5;
				};
				// 3
				if (_index in [8,20,32]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX * 0.293;
					_ctrlY = (safeZoneH - _ctrlHeigth) / 2 + safeZoneY * 2.73;
					_ctrlAngle = 90;
				};
				if (_index in [9,21,33]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX * 0.157;
					_ctrlY = (safeZoneH - _ctrlHeigth) / 2 + safeZoneY * 1.65;
					_ctrlAngle = 112.5;
				};
				if (_index in [10,22,34]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX * 0.153;
					_ctrlY = (safeZoneH - _ctrlHeigth) / 2 + safeZoneY * 0.46;
					_ctrlAngle = 135;
				};
				if (_index in [11,23,35]) exitWith {
					_ctrlX = (safeZoneW - _ctrlWidth) / 2 + safeZoneX * 0.277;
					_ctrlY = (safeZoneH - _ctrlHeigth) / 2 + safeZoneY * -0.65;
					_ctrlAngle = 157.5;
				};
			};

			if (_elemID == 1) then {
				_ctrlText = "lvl3.paa";
			} else {
				_ctrlWidth = _ctrlWidth / 2;
				_ctrlHeigth = _ctrlHeigth / 2;
				_ctrlX = _ctrlX + _ctrlWidth / 2;
				_ctrlY = _ctrlY + _ctrlHeigth / 2;

				private _padding = safeZoneH * 0.5;
				_ctrlText = ["", str (_index + 1)] select (_index < 32);
				_ctrlText = format ["<t size='%2'>&#160;</t><br/><t size='1' align='center'>%1</t>", _ctrlText, _padding];
			
				_ctrl ctrlSetTooltip str _index;
			};
		};
	};

	_ctrl ctrlSetPosition [_ctrlX, _ctrlY, _ctrlWidth, _ctrlHeigth];
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
	//_ctrl ctrlEnable false;
	//_ctrl ctrlShow false;

	// добавление элемента в общий массив в виде массива [фон, текст]
	private _items = localNamespace getVariable ["animGUI_items", [[],[],[]]];
	(_items # _lvl) set [_elemID, _ctrl];
	localNamespace setVariable ["animGUI_items", _items];
};