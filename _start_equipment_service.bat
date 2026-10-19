@echo off
if exist "H:\Create with Anti\EquipmentBookingSystem" (
    cd /d "H:\Create with Anti\EquipmentBookingSystem"
) else (
    cd /d "C:\ARFabServices\EquipmentBookingSystem"
)
call "C:\Program Files\nodejs\npm.cmd" run start > "%~dp0_equipment.log" 2>&1
