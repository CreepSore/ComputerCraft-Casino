CFG = {
    DEBUG="true",
    MODEM_SIDE="front",
    CABLE_SIDE="right",
    CABLE={
        speaker="speaker_1",
        monitor="monitor_0",
        inventory_in="minecraft:barrel_0",
        inventory_out="minecraft:barrel_1"
    },
    PROTO={
        GET_MAINFRAME="Casino/mainframe/get",
        USER={
            NEW="Casino/user/new",
            INFO="Casino/user/info",
            TRANSACTION={
                SUBTRACT="Casino/user/transaction/subtract",
                ADD="Casino/user/transaction/add"
            }
        }
    },
    FILES={
        USERID="disk/userid.dat",
        LOGON="disk/logon.dat"
    },
    mapping={
        ["minecraft:iron_ingot"] = {amount=10, name="Iron Ingot"},
        ["minecraft:gold_ingot"] = {amount=20, name="Gold Ingot"},
        ["minecraft:diamond"] = {amount=100, name="Diamond"},
        ["minecraft:emerald"] = {amount=1000, name="Emerald"},
        ["allthemodium:allthemodium_ingot"] = {amount=10000, name="Allthemodium"},
        ["allthemodium:vibranium_ingot"] = {amount=25000, name="Vibranium"},
        ["allthemodium:unobtainium_ingot"] = {amount=50000, name="Unobtainium"}
    }
}