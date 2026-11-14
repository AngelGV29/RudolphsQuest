/// @description Inicializa los recursos de la partida

//Conservar una sola instancia del controlador
if (instance_number(objGame) > 1)
{
    instance_destroy();
    exit;
}

persistent = true;

//Recursos acumulados
Score = 0;
Coins = 0;
Diamonds = 0;

//Estadísticas del intento actual
LevelScore = 0;
LevelCoins = 0;
LevelDiamonds = 0;

//Configuración de vidas
MaxLives = 99;
StartingLives = 3;
Lives = StartingLives;

//Recompensas configurables
CoinPoints = 50;
CoinsPerLife = 100;
//Valor provisional del diamante
DiamondPoints = 100;
DiamondsPerLife = 50;

//Reproducciones activas de sonidos de recogida
PickupSoundVoices = [];

//Configuración provisional
PickupSoundMaxVoices = 4;
PickupSoundGain = 0.55;

//Aviso independiente de vida extra
ExtraLifeSound = sndExtraLive;
ExtraLifeSoundVoice = -1;

ExtraLifeSoundPriority = 5;
ExtraLifeSoundGain = 1;

//Comenzar un nuevo intento del nivel
ResetLevelStats = function()
{
    LevelScore = 0;
    LevelCoins = 0;
    LevelDiamonds = 0;
};

//Añadir puntaje acumulado y del intento
AddScore = function(Amount)
{
    var Points = max(0, floor(Amount));

    Score += Points;
    LevelScore += Points;
};

//Añadir vidas y avisar solamente si aumentaron
//Conceder una recompensa de vidas y reproducir su aviso
AddLives = function(Amount)
{
    var Count = max(0, floor(Amount));

    if (Count == 0)
    {
        return 0;
    }

    var PreviousLives = Lives;

    Lives = min(
        Lives + Count,
        MaxLives
    );

    //El aviso representa la recompensa, incluso con 99 vidas
    var CanPlaySound = true;

    if (ExtraLifeSoundVoice != -1)
    {
        CanPlaySound = !audio_is_playing(
            ExtraLifeSoundVoice
        );
    }

    if (CanPlaySound && ExtraLifeSound != -1)
    {
        ExtraLifeSoundVoice = audio_play_sound(
            ExtraLifeSound,
            ExtraLifeSoundPriority,
            false,
            ExtraLifeSoundGain
        );
    }

    return Lives - PreviousLives;
};

//Conceder monedas y sus recompensas
AddCoins = function(Amount)
{
    var Count = max(0, floor(Amount));

    if (Count == 0)
    {
        return;
    }

    LevelCoins += Count;

    AddScore(Count * CoinPoints);

    var TotalCoins = Coins + Count;
    var ExtraLives = TotalCoins div CoinsPerLife;

    Coins = TotalCoins mod CoinsPerLife;

    if (ExtraLives > 0)
    {
        AddLives(ExtraLives);
    }
};

//Conceder diamantes y sus recompensas
AddDiamonds = function(Amount)
{
    var Count = max(0, floor(Amount));

    if (Count == 0)
    {
        return;
    }

    LevelDiamonds += Count;

    AddScore(Count * DiamondPoints);
    
    var TotalDiamonds = Diamonds + Count;
    var ExtraLives = TotalDiamonds div DiamondsPerLife;
    
    Diamonds = TotalDiamonds mod DiamondsPerLife;
    
    if (ExtraLives > 0)
    {
        AddLives(ExtraLives);
    }
};

//Restaurar los datos de una partida nueva
ResetRun = function()
{
    //Detener los sonidos de recogida que sigan activos
    var VoiceCount = array_length(PickupSoundVoices);

    for (var Index = 0; Index < VoiceCount; Index += 1)
    {
        var Voice = PickupSoundVoices[Index];

        if (audio_is_playing(Voice))
        {
            audio_stop_sound(Voice);
        }
    }

    PickupSoundVoices = [];
    
    //Detener el aviso de vida extra al restaurar la partida
    if (ExtraLifeSoundVoice != -1)
    {
        if (audio_is_playing(ExtraLifeSoundVoice))
        {
            audio_stop_sound(ExtraLifeSoundVoice);
        }
    }
    
    ExtraLifeSoundVoice = -1;

    //Recursos acumulados
    Score = 0;
    Coins = 0;
    Diamonds = 0;

    //Vidas iniciales
    Lives = StartingLives;

    //Estadísticas del intento
    ResetLevelStats();
};

//Fin de partida provisional para pruebas
GameOver = function()
{
    show_debug_message(
        "GAME OVER: se agotaron las vidas. Reiniciando partida."
    );

    ResetRun();

    room_restart();
};

//Resolver una muerte después de su secuencia audiovisual
CompletePlayerDeath = function()
{
    Lives = max(Lives - 1, 0);

    show_debug_message(
        "Muerte resuelta. Vidas restantes: " + string(Lives)
    );

    if (Lives <= 0)
    {
        GameOver();
        return;
    }

    //Conservar acumulados y comenzar otro intento
    room_restart();
};