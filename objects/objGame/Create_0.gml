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

//Valor provisional para probar las vidas extra
Lives = 3;

//Recompensas configurables
CoinPoints = 50;
CoinsPerLife = 100;

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

//Añadir vidas extra
AddLives = function(Amount)
{
    Lives += max(0, floor(Amount));
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