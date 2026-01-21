Config = {}

Config.InteractionKey = 38
Config.InteractionDistance = 2.5
Config.UseTarget = true
Config.Framework = "standalone"
Config.EnableVoice = true
Config.EnableBlips = true
Config.EnablePrompts = false

Config.VoiceAPI = {
    enabled = true,
    provider = "elevenlabs",

    responsiveVoice = {
        key = "YOUR_FREE_KEY",
        defaultVoice = "UK English Male",
        pitch = 1.0,
        rate = 0.9,
        volume = 1.0
    },

    elevenLabs = {
        apiKey = "sk_79cbf73621dae84d19e6d68cdd12c8e69fb2eea24aabd72d",
        voices = {man = "JBFqnCBsd6RMkjVDRZzb"}
    }
}

Config.NPCs = {
    {
        id = "ems_01",
        name = "DR. john - EMERGENCY SERVICES",
        model = "s_m_m_paramedic_01",

        spawn = {
            coords = vector4(308.52, -596.46, 43.29, 21.49),
            frozen = true,
            invincible = true,
            blockevents = true
        },

        blip = {
            enabled = true,
            sprite = 61,
            color = 1,
            scale = 0.8,
            label = "Emergency Medical Services"
        },

        dialogues = {
            {
                id = 1,
                text = "Hello! I'm Dr. john from EMS. How can I assist you today?",
                voice = {
                    enabled = true,
                    voiceId = "JBFqnCBsd6RMkjVDRZzb",
                    pitch = 1.1,
                    rate = 0.9,
                    volume = 1.0
                },
                animation = {
                    dict = "gestures@m@standing@casual",
                    anim = "gesture_hello",
                    duration = 2000,
                    flag = 49
                },
                options = {
                    {label = "I need help", nextDialogue = 2, action = nil},
                    {
                        label = "Close",
                        nextDialogue = nil,
                        action = {type = "close"}
                    }
                }
            }, {
                id = 2,
                text = "Of course! Let me check what medical assistance you need. Are you injured or just need a general checkup?",
                voice = {
                    enabled = true,
                    voiceId = "JBFqnCBsd6RMkjVDRZzb",
                    pitch = 1.1,
                    rate = 0.9,
                    volume = 1.0
                },
                animation = {
                    dict = "amb@medic@standing@kneel@base",
                    anim = "base",
                    duration = 2000,
                    flag = 49
                },
                options = {
                    {
                        label = "Check-in for medical examination",
                        nextDialogue = nil,
                        action = {
                            type = "trigger_event",
                            event = "hospital:client:Revive"
                        }
                    },
                    {
                        label = "I'm injured, need treatment",
                        nextDialogue = 3,
                        action = nil
                    }, {label = "Never mind", nextDialogue = 1, action = nil}
                }
            }, {
                id = 3,
                text = "Let me take a look at your injuries right away. Please hold still while I assess your condition.",
                voice = {
                    enabled = true,
                    voiceId = "JBFqnCBsd6RMkjVDRZzb",
                    pitch = 1.1,
                    rate = 0.9,
                    volume = 1.0
                },
                animation = {
                    dict = "amb@medic@standing@tendtodead@base",
                    anim = "base",
                    duration = 3000,
                    flag = 49
                },
                options = {
                    {
                        label = "Proceed with treatment",
                        nextDialogue = nil,
                        action = {
                            type = "trigger_event",
                            event = "ems:startTreatment",
                            params = {
                                npcId = "ems_01",
                                treatmentType = "injury"
                            }
                        }
                    }, {label = "Cancel", nextDialogue = 1, action = nil}
                }
            }
        },

        events = {
            onSpawn = {
                type = "server_event",
                event = "cl-npc:logSpawn",
                params = {npcId = "ems_01"}
            },
            onInteract = {
                type = "client_event",
                event = "cl-npc:playSound",
                params = {sound = "interaction", volume = 0.5}
            },
            onDialogueComplete = {
                type = "trigger_event",
                event = "ems:logInteraction",
                params = {emsId = "ems_01"}
            }
        },

        ambientAnimations = {
            enabled = true,
            frequency = 30000,
            animations = {
                {
                    dict = "amb@world_human_clipboard@male@idle_a",
                    anim = "idle_a",
                    duration = 8000,
                    flag = 49
                }, {
                    dict = "amb@world_human_stand_mobile@male@text@base",
                    anim = "base",
                    duration = 6000,
                    flag = 49
                }
            }
        }
    }
}

Config.UI = {
    dialogueBox = {
        position = {x = 0.5, y = 0.75},
        width = 0.45,
        backgroundColor = {r = 0, g = 0, b = 0, a = 200},
        borderColor = {r = 255, g = 255, b = 255, a = 255},
        borderWidth = 2
    },

    npcName = {
        fontSize = 0.5,
        color = {r = 255, g = 200, b = 50, a = 255},
        font = 4
    },

    dialogueText = {
        fontSize = 0.4,
        color = {r = 255, g = 255, b = 255, a = 255},
        font = 4,
        lineSpacing = 1.2
    },

    options = {
        fontSize = 0.38,
        color = {r = 200, g = 200, b = 200, a = 255},
        hoverColor = {r = 255, g = 255, b = 255, a = 255},
        selectedColor = {r = 50, g = 150, b = 255, a = 255},
        font = 4,
        spacing = 0.03
    },

    prompt3D = {
        text = "[E] Talk",
        fontSize = 0.4,
        color = {r = 255, g = 255, b = 255, a = 255},
        font = 4,
        distance = 2.5
    }
}

Config.Sounds = {
    interactionSound = {
        enabled = true,
        name = "SELECT",
        set = "HUD_FRONTEND_DEFAULT_SOUNDSET"
    },
    optionHoverSound = {
        enabled = true,
        name = "NAV_UP_DOWN",
        set = "HUD_FRONTEND_DEFAULT_SOUNDSET"
    },
    optionSelectSound = {
        enabled = true,
        name = "SELECT",
        set = "HUD_FRONTEND_DEFAULT_SOUNDSET"
    }
}

Config.PreloadAnimations = {
    "gestures@m@standing@casual", "gestures@f@standing@casual", "mp_common",
    "mini@sprunk", "missheistdockssetup1clipboard@base", "mini@repair",
    "amb@world_human_smoking@male@male_a@idle_a",
    "amb@world_human_clipboard@male@idle_a",
    "amb@world_human_stand_mobile@female@text@base",
    "amb@world_human_welding@male@base", "amb@world_human_hammering@male@base"
}

Config.Debug = false
