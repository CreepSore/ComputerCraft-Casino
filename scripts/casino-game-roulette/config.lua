CFG = {
    DEBUG="true",
    MODEM_SIDE="top",
    CABLE_SIDE="back",
    CABLE={
        speaker="speaker_2",
        monitor_input="monitor_1",
        monitor_bets="monitor_3",
        monitor_wheel="monitor_2"
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
    MAX_PLAYERS = 4
}