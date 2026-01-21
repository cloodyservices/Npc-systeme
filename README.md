# cl-npc

Advanced NPC dialogue system with AI voice integration for FiveM

**Author:** cLo_oDy

---

## 📋 Features

- **Interactive NPCs** with customizable dialogues and branching conversations
- **AI Voice Integration** supporting multiple providers:
  - ElevenLabs (Premium quality)
  - ResponsiveVoice (Free alternative)
- **Dynamic Animations** for NPCs including ambient behaviors
- **Event System** for triggering server/client events
- **Customizable UI** with full styling options
- **Built-in Sound Effects** for enhanced user experience
- **Map Blips** for easy NPC location identification
- **Framework Support** (Standalone by default, easily adaptable)

---

## 🎯 Configuration Overview

### Core Settings

```lua
Config.InteractionKey = 38           -- E key by default
Config.InteractionDistance = 2.5     -- Distance to interact with NPCs
Config.UseTarget = true              -- Enable target system
Config.Framework = "standalone"      -- Framework type
Config.EnableVoice = true            -- Enable voice responses
Config.EnableBlips = true            -- Show NPCs on map
Config.EnablePrompts = false         -- 3D prompts
```

---

## 🎤 Voice API Configuration

### ElevenLabs (Recommended)

High-quality AI voice generation with natural speech.

```lua
elevenLabs = {
    apiKey = "YOUR_API_KEY_HERE",
    voices = {
        man = "VOICE_ID_HERE",
    }
}
```

**Get your API key:** [ElevenLabs](https://elevenlabs.io/)

### ResponsiveVoice (Free Alternative)

```lua
responsiveVoice = {
    key = "YOUR_FREE_KEY",
    defaultVoice = "UK English Male",
    pitch = 1.0,
    rate = 0.9,
    volume = 1.0
}
```

---

## 👤 NPC Configuration

Each NPC can be configured with:

### Basic Setup
- `id` - Unique identifier
- `name` - Display name
- `model` - Ped model hash
- `spawn` - Coordinates and spawn settings

### Spawn Options
```lua
spawn = {
    coords = vector4(x, y, z, heading),
    frozen = true,
    invincible = true,
    blockevents = true,
}
```

### Map Blip
```lua
blip = {
    enabled = true,
    sprite = 61,
    color = 1,
    scale = 0.8,
    label = "NPC Location"
}
```

### Dialogue System

Create branching conversations with:
- Text messages
- Voice responses
- Animations
- Multiple choice options
- Event triggers

```lua
dialogues = {
    {
        id = 1,
        text = "Hello! How can I help you?",
        voice = { ... },
        animation = { ... },
        options = { ... }
    }
}
```

### Voice Settings Per Dialogue
```lua
voice = {
    enabled = true,
    voiceId = "ELEVENLABS_VOICE_ID",
    pitch = 1.1,
    rate = 0.9,
    volume = 1.0
}
```

### Animation Settings
```lua
animation = {
    dict = "gestures@m@standing@casual",
    anim = "gesture_hello",
    duration = 2000,
    flag = 49
}
```

### Dialogue Options

Link dialogues together and trigger actions:

```lua
options = {
    {
        label = "Option text",
        nextDialogue = 2,  -- ID of next dialogue
        action = {
            type = "trigger_event",
            event = "event:name",
            params = { ... }
        }
    }
}
```

**Action Types:**
- `trigger_event` - Trigger client event
- `close` - Close dialogue

---

## 🎬 Event System

Configure events that trigger on specific actions:

```lua
events = {
    onSpawn = {
        type = "server_event",
        event = "event:name",
        params = { ... }
    },
    onInteract = {
        type = "client_event",
        event = "event:name",
        params = { ... }
    },
    onDialogueComplete = {
        type = "trigger_event",
        event = "event:name",
        params = { ... }
    }
}
```

---

## 🎭 Ambient Animations

Make NPCs feel alive with periodic animations:

```lua
ambientAnimations = {
    enabled = true,
    frequency = 30000,  -- Every 30 seconds
    animations = {
        {dict = "animation_dict", anim = "animation_name", duration = 8000, flag = 49},
    }
}
```

---

## 🎨 UI Customization

Fully customize the dialogue interface:

### Dialogue Box
```lua
dialogueBox = {
    position = {x = 0.5, y = 0.75},
    width = 0.45,
    backgroundColor = {r = 0, g = 0, b = 0, a = 200},
    borderColor = {r = 255, g = 255, b = 255, a = 255},
    borderWidth = 2,
}
```

### Text Styling
- NPC Name
- Dialogue Text
- Options
- 3D Prompts

All with customizable colors, fonts, and sizes.

---

## 🔊 Sound Effects

Built-in sounds for better UX:

```lua
Config.Sounds = {
    interactionSound = { ... },
    optionHoverSound = { ... },
    optionSelectSound = { ... }
}
```

---

## ⚙️ Installation

1. Extract `cl-npc` to your resources folder
2. Add `ensure cl-npc` to your `server.cfg`
3. Configure your NPCs in `config.lua`
4. Add your ElevenLabs API key (or use ResponsiveVoice)
5. Restart your server

---

## 📝 Example NPC

The config includes a fully functional EMS NPC example with:
- Multiple dialogue branches
- Voice responses
- Animations
- Event triggers
- Treatment system integration

Use it as a template for creating your own NPCs!

---

## 🐛 Debug Mode

Enable debug mode for development:

```lua
Config.Debug = true
```

---

## 📄 License

This resource is created by **cLo_oDy**

---

## 🤝 Support

For issues, questions, or feature requests, please contact the author.
https://discord.gg/5ARf3Qhfkc
---

## 🎯 Tips

1. **Voice IDs**: Get voice IDs from ElevenLabs voice library
2. **Animations**: Use animation dictionaries from FiveM documentation
3. **Performance**: Limit ambient animation frequency for better performance
4. **Testing**: Enable debug mode while configuring NPCs
5. **Events**: Make sure triggered events exist in your other resources

---

**Enjoy creating immersive NPC experiences with cl-npc!** 🚀
