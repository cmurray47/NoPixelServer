Config = {}

Config.MOVE_DISTANCE = {
    x = 0.5,
    y = 0.5,
    z = 0.2,
    h = 3
}

Config.CONTROLS = {
    keyboard = {
        openMenu    = 178,  -- Delete
        hold        = 21,   -- Shift
        speedUp     = 15,   -- Mouse wheel up   -- with hold
        speedDown   = 14,   -- Mouse wheel down -- with hold

        zoomOut     = 14,   -- Mouse wheel down
        zoomIn      = 15,   -- Mouse wheel up

        forwards    = 32,   -- W
        backwards   = 33,   -- S
        left        = 34,   -- A
        right       = 35,   -- D
        up          = 22,   -- Space
        down        = 36,   -- Ctrl

        rollLeft    = 44,   -- Q
        rollRight   = 38,   -- E

        upArrow     = 27,
        downArrow   = 173,

        leftMouse   = 24,
        rightMouse  = 25,

    },
    controller = {
        openMenu    = 244,  -- Select -- hold for ~1 second

        holdSpeed   = 80,   -- O / B
        holdFov     = 21,   -- X / A
        up          = 172,  -- D-pad up
        down        = 173,  -- D-pad down

        rollLeft    = 37,   -- L1 / LB
        rollRight   = 44,   -- R1 / RB
    }
}

Config.DISABLED_CONTROLS = {
    30,     -- A and D (Character Movement)
    31,     -- W and S (Character Movement)
    21,     -- LEFT SHIFT
    36,     -- LEFT CTRL
    22,     -- SPACE
    44,     -- Q
    38,     -- E
    71,     -- W (Vehicle Movement)
    72,     -- S (Vehicle Movement)
    59,     -- A and D (Vehicle Movement)
    60,     -- LEFT SHIFT and LEFT CTRL (Vehicle Movement)
    85,     -- Q (Radio Wheel)
    86,     -- E (Vehicle Horn)
    15,     -- Mouse wheel up
    14,     -- Mouse wheel down
    37,     -- Controller R1 (PS) / RT (XBOX)
    80,     -- Controller O (PS) / B (XBOX)
    228,    -- 
    229,    -- 
    172,    -- 
    173,    -- 
    37,     -- 
    44,     -- 
    178,    -- 
    244,    -- 
}