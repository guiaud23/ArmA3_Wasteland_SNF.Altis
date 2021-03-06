// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright � 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: changeOwner.sqf
//	@file Author: AgentRev
//	@file edited: CRE4MPIE
//	@credits to: Cael817, Lodac, Wiking, Gigatek (original auth of chopshop)
//	@Info: For this to (fully) work on townvehciles you will need to add a check for ownerUID or A3WPurchasedVehicle in vehicleRespawnManager.sqf


#include "sellIncludesStart.sqf";

storeSellingHandle = _this spawn
{
#define CHANGEOWNER_PRICE_RELATIONSHIP 2
#define VEHICLE_MAX_SELLING_DISTANCE 50

private ["_vehicle","_type", "_price", "_confirmMsg", "_playerMoney", "_text", "_variables"];

_storeNPC = _this select 0;
_vehicle = objectFromNetId (player getVariable ["lastVehicleRidden", ""]);
_type = typeOf _vehicle;
_playerMoney = player getVariable "cmoney";
_price = 500;

	if (isNull _vehicle) exitWith
	{
		playSound "FD_CP_Not_Clear_F";
		["Your previous vehicle does not exist anymore.", "Error"] call  BIS_fnc_guiMessage;
	};

	if (_vehicle distance _storeNPC > VEHICLE_MAX_SELLING_DISTANCE) exitWith
	{
		playSound "FD_CP_Not_Clear_F";
		[format ['"%1" is further away than %2m from the store.', _type, VEHICLE_MAX_SELLING_DISTANCE], "Error"] call  BIS_fnc_guiMessage;
	};
	
{	
	if (_type == _x select 1) then
	{	
	_price = _x select 2;
	_price = _price / CHANGEOWNER_PRICE_RELATIONSHIP;
	};
	
} forEach (call allVehStoreVehicles);

	if (!isNil "_price") then 
	{
		// Add total cost to confirm message
		_confirmMsg = format ["Changing owner on %1 will cost you $%2 for:<br/>", _type, _price];
		_confirmMsg = _confirmMsg + format ["<br/><t font='EtelkaMonospaceProBold'>1</t> x %1", _type];

		// Display confirm message
		if ([parseText _confirmMsg, "Confirm", "OK", true] call BIS_fnc_guiMessage) then
		{
			_vehicle setVariable ["A3W_missionVehicle", nil, true];
			_vehicle setVariable ["A3W_townVehicle", nil, true];
			_vehicle setFuel 1;
			_vehicle setDamage 0;
			_vehicle setVariable ["A3W_purchasedVehicle", true, true];
			_vehicle setVariable ["ownerUID", getPlayerUID player, true];
			_vehicle setVariable ["ownerName", name player, true];

			player setVariable["cmoney",(player getVariable "cmoney")-_price,true];
			_ownerName = _Vehicle getvariable "ownerName";
			_text = format ["Ownership on %1 is set to %2, vehicle is repaired and refuelled", _type, _ownerName];
			[_text, 10] call mf_notify_client;
			
		if (["A3W_playerSaving"] call isConfigOn) then
		{
				[] spawn fn_savePlayerData;
		};
		 };
	} else {
		hint parseText "<t color='#ffff00'>An unknown error occurred.</t><br/>Cancelled.";
		playSound "FD_CP_Not_Clear_F";
	};
};	
		
#include "sellIncludesEnd.sqf";
