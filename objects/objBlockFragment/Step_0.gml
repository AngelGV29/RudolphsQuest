/// @description Actualiza la caída del fragmento

VSpeed = min(
    VSpeed + Gravity,
    MaxFallSpeed
);

x += HSpeed;
y += VSpeed;

image_angle += SpinSpeed;

LifeTimer += 1;

//Límite de seguridad aunque la cámara se aleje
if (LifeTimer >= LifeFrames || y > room_height + 32)
{
    instance_destroy();
    exit;
}

//Eliminarlo cuando ya cae por debajo de la cámara
var Camera = view_camera[0];

if (Camera != -1 && VSpeed > 0)
{
    var ViewBottom =
        camera_get_view_y(Camera)
        + camera_get_view_height(Camera);

    if (y > ViewBottom + 32)
    {
        instance_destroy();
    }
}