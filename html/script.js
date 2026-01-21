let currentDialogue = null;
let currentAudio = null;

window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.type === 'openDialogue') {
        openDialogue(data);
    } else if (data.type === 'closeDialogue') {
        closeDialogue();
    } else if (data.type === 'speak') {
        speakText(data);
    } else if (data.type === 'stopSpeech') {
        stopSpeech();
    }
});

function openDialogue(data) {
    const container = document.getElementById('dialogue-container');
    const npcName = document.getElementById('npc-name');
    const dialogueText = document.getElementById('dialogue-text');
    const optionsContainer = document.getElementById('options-container');
    const voiceIndicator = document.getElementById('voice-indicator');
    currentDialogue = data;
    npcName.textContent = data.npcName;
    const textContent = data.text;
    dialogueText.innerHTML = textContent;
    if (voiceIndicator) {
        dialogueText.appendChild(voiceIndicator);
    }
    optionsContainer.innerHTML = '';
    data.options.forEach((option, index) => {
        const optionDiv = document.createElement('div');
        optionDiv.className = 'option';
        optionDiv.textContent = option.label;
        optionDiv.setAttribute('data-index', index + 1);
        optionDiv.addEventListener('mouseenter', () => {
            fetch(`https://${GetParentResourceName()}/hoverOption`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ index: index + 1 })
            });
        });
        optionDiv.addEventListener('click', () => {
            fetch(`https://${GetParentResourceName()}/selectOption`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ index: index + 1 })
            });
        });
        optionsContainer.appendChild(optionDiv);
    });
    container.style.display = 'block';
}

function closeDialogue() {
    const container = document.getElementById('dialogue-container');
    if (container) {
        container.style.display = 'none';
    }
    stopSpeech();
}

async function speakText(data) {
    stopSpeech();
    const voiceIndicator = document.getElementById('voice-indicator');
    if (voiceIndicator) {
        voiceIndicator.classList.add('speaking');
    }
    try {
        const text = data.text;
        const voiceId = data.voiceId;
        const provider = data.provider || 'elevenlabs';
        if (provider === 'elevenlabs' && data.apiKey) {
            await speakWithElevenLabs(text, voiceId, data.apiKey);
        } else if (typeof responsiveVoice !== 'undefined') {
            responsiveVoice.speak(text, voiceId || "UK English Male", {
                pitch: data.pitch || 1,
                rate: data.rate || 0.9,
                volume: data.volume || 1,
                onend: () => {
                    if (voiceIndicator) {
                        voiceIndicator.classList.remove('speaking');
                    }
                }
            });
        } else {
            const utterance = new SpeechSynthesisUtterance(text);
            utterance.pitch = data.pitch || 1.0;
            utterance.rate = data.rate || 0.9;
            utterance.volume = data.volume || 1.0;
            utterance.onend = () => {
                if (voiceIndicator) {
                    voiceIndicator.classList.remove('speaking');
                }
            };
            speechSynthesis.speak(utterance);
        }
    } catch (error) {
        console.error('TTS Error:', error);
        const voiceIndicator = document.getElementById('voice-indicator');
        if (voiceIndicator) {
            voiceIndicator.classList.remove('speaking');
        }
    }
}

async function speakWithElevenLabs(text, voiceId, apiKey) {
    const voiceIndicator = document.getElementById('voice-indicator');
    try {
        if (!apiKey || apiKey === 'your_api_key_here' || apiKey === 'YOUR_ELEVENLABS_API_KEY') {
            console.error('ElevenLabs API key not configured! Please set your API key in config.lua');
            throw new Error('Invalid API key - Please configure in config.lua');
        }
        const response = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${voiceId}`, {
            method: 'POST',
            headers: {
                'Accept': 'audio/mpeg',
                'Content-Type': 'application/json',
                'xi-api-key': apiKey
            },
            body: JSON.stringify({
                text: text,
                model_id: 'eleven_turbo_v2_5',
                voice_settings: {
                    stability: 0.5,
                    similarity_boost: 0.75,
                    style: 0.0,
                    use_speaker_boost: true
                }
            })
        });
        if (!response.ok) {
            const errorText = await response.text();
            if (response.status === 401) {
                throw new Error('Invalid API key - Check console for details');
            } else if (response.status === 429) {
                throw new Error('Rate limit exceeded');
            } else {
                throw new Error(`ElevenLabs API error: ${response.status} - ${errorText}`);
            }
        }
        const audioBlob = await response.blob();
        const audioUrl = URL.createObjectURL(audioBlob);
        currentAudio = new Audio(audioUrl);
        currentAudio.volume = 1.0;
        currentAudio.onended = () => {
            if (voiceIndicator) {
                voiceIndicator.classList.remove('speaking');
            }
            URL.revokeObjectURL(audioUrl);
        };
        currentAudio.onerror = (e) => {
            console.error('Audio playback error:', e);
            if (voiceIndicator) {
                voiceIndicator.classList.remove('speaking');
            }
        };
        await currentAudio.play();

    } catch (error) {
        console.error('ElevenLabs TTS Error:', error.message);
        if (voiceIndicator) {
            voiceIndicator.classList.remove('speaking');
        }
        const utterance = new SpeechSynthesisUtterance(text);
        utterance.pitch = 1.0;
        utterance.rate = 0.9;
        utterance.volume = 1.0;
        utterance.onend = () => {
            if (voiceIndicator) {
                voiceIndicator.classList.remove('speaking');
            }
        };
        speechSynthesis.speak(utterance);
    }
}

function stopSpeech() {
    const voiceIndicator = document.getElementById('voice-indicator');
    if (voiceIndicator) {
        voiceIndicator.classList.remove('speaking');
    }
    if (currentAudio) {
        currentAudio.pause();
        currentAudio.currentTime = 0;
        currentAudio = null;
    }
    if (typeof responsiveVoice !== 'undefined') {
        responsiveVoice.cancel();
    }
    if (window.speechSynthesis && speechSynthesis.speaking) {
        speechSynthesis.cancel();
    }
}

document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape' && currentDialogue) {
        closeDialogue();
        fetch(`https://${GetParentResourceName()}/closeDialogue`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
});