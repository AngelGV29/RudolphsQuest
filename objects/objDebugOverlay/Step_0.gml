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

//Esperar a que se complete el cambio de modo
if (WindowChangeTimer > 0)
{
    WindowChangeTimer -= 1;

    if (
        WindowChangeTimer == 0
        && WindowRestorePending
    )
    {
        if (!window_get_fullscreen())
        {
            window_set_size(
                SavedWindowWidth,
                SavedWindowHeight
            );

            window_set_position(
                SavedWindowX,
                SavedWindowY
            );
        }

        WindowRestorePending = false;
    }
}

//Alternar pantalla completa con P
if (
    keyboard_check_pressed(ord("P"))
    && WindowChangeTimer == 0
)
{
    if (!window_get_fullscreen())
    {
        //Guardar el tamaño y la posición actuales
        SavedWindowWidth = window_get_width();
        SavedWindowHeight = window_get_height();

        SavedWindowX = window_get_x();
        SavedWindowY = window_get_y();

        window_set_fullscreen(true);

        WindowRestorePending = false;
        WindowChangeTimer = 10;
    }
    else
    {
        window_set_fullscreen(false);

        //Restaurar la ventana después de completar la transición
        WindowRestorePending = true;
        WindowChangeTimer = 10;
    }
}