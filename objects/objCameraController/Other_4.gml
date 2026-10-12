/// @description Obtiene la cámara y el jugador de la habitación

CameraId = view_camera[0];
Target = instance_find(objPlayer, 0);

if (CameraId != -1)
{
    camera_set_view_size(
        CameraId,
        ViewWidth,
        ViewHeight
    );
}

Initialized = false;