/// @description Inicializa las marcas de depuración

if (instance_number(objDebugOverlay) > 1)
{
    instance_destroy();
    exit;
}

persistent = true;

//Todas comienzan ocultas
ShowPlayer = false;
ShowHammer = false;
ShowPickupArea = false;
ShowEnemies = false;
ShowPickups = false;
ShowProjectiles = false;

//Dibujar una región con relleno suave y borde opaco
DrawBox = function(Left, Top, Right, Bottom, Color)
{
    draw_set_color(Color);

    draw_set_alpha(0.12);

    draw_rectangle(
        Left,
        Top,
        Right,
        Bottom,
        false
    );

    draw_set_alpha(1);

    draw_rectangle(
        Left,
        Top,
        Right,
        Bottom,
        true
    );
};
