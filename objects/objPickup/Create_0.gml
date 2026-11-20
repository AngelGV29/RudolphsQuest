/// @description Inicializa las propiedades comunes de los recogibles

//Evitar entregar una recompensa más de una vez
Collected = false;

//Permitir recogida mediante enemigos lanzados
CanCollectByThrown = false;

//Sonido opcional de recogida
PickupSound = -1;
PickupSoundPriority = 1;

CurrentNumSounds = 0;
MaxSounds = 3;

//Reproducir recogidas con superposición limitada
PlayPickupSound = function(Game)
{
    if (PickupSound == -1)
    {
        return;
    }

    //Conservar solo las reproducciones que siguen activas
    var ActiveVoices = [];

    var VoiceCount = array_length(
        Game.PickupSoundVoices
    );

    for (var Index = 0; Index < VoiceCount; Index += 1)
    {
        var Voice = Game.PickupSoundVoices[Index];

        if (audio_is_playing(Voice))
        {
            array_push(ActiveVoices, Voice);
        }
    }

    var MaxVoices = max(
        1,
        floor(Game.PickupSoundMaxVoices)
    );

    //Reservar espacio retirando las más antiguas
    while (array_length(ActiveVoices) >= MaxVoices)
    {
        var OldestVoice = ActiveVoices[0];

        audio_stop_sound(OldestVoice);

        array_delete(ActiveVoices, 0, 1);
    }

    //Cada recogida comienza inmediatamente
    var NewVoice = audio_play_sound(
        PickupSound,
        PickupSoundPriority,
        false,
        Game.PickupSoundGain
    );

    if (NewVoice != -1)
    {
        array_push(ActiveVoices, NewVoice);
    }

    Game.PickupSoundVoices = ActiveVoices;
};

//Cada hijo define su recompensa
ApplyReward = function(Game, Player)
{
    return false;
};

//Validar y procesar una recogida
TryCollect = function(Player, ByThrown)
{
    if (Collected)
    {
        return false;
    }

    if (!instance_exists(Player))
    {
        return false;
    }

    if (Player.ActionState == PLAYER_ACTION_STATE.DEAD)
    {
        return false;
    }

    if (ByThrown && !CanCollectByThrown)
    {
        return false;
    }

    var Game = instance_find(objGame, 0);

    if (!instance_exists(Game))
    {
        return false;
    }

    //Bloquear cualquier segundo intento
    Collected = true;

    if (!ApplyReward(Game, Player))
    {
        Collected = false;
        return false;
    }
    
    //Sonar únicamente después de conceder la recompensa
    PlayPickupSound(Game);

    instance_destroy();

    return true;
};