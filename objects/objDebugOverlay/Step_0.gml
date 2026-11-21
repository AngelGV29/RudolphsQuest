/// @description Alterna las marcas con las teclas numéricas

if (keyboard_check_pressed(ord("1")))
{
    ShowPlayer = !ShowPlayer;
}

if (keyboard_check_pressed(ord("2")))
{
    ShowHammer = !ShowHammer;
}

if (keyboard_check_pressed(ord("3")))
{
    ShowPickupArea = !ShowPickupArea;
}

if (keyboard_check_pressed(ord("4")))
{
    ShowEnemies = !ShowEnemies;
}

if (keyboard_check_pressed(ord("5")))
{
    ShowPickups = !ShowPickups;
}

if (keyboard_check_pressed(ord("6")))
{
    ShowProjectiles = !ShowProjectiles;
}