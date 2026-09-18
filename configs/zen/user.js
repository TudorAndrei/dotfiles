// GPU Hardware Acceleration for NVIDIA + VA-API
// Video Decoding
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.ffmpeg.vaapi-drm.enable", true);
user_pref("media.navigator.mediadataencoder_vpx_enabled", true);
user_pref("media.navigator.mediadataencoder_av1_enabled", true);

// WebRender GPU Acceleration
user_pref("gfx.webrender.all", true);
user_pref("gfx.webrender.compositor", true);
user_pref("layers.acceleration.force-enabled", true);
user_pref("layers.gpu-process.force-enabled", true);

// WebGL
user_pref("webgl.force-enabled", true);

// Hardware Video Decoding
user_pref("media.hardware-video-decoding.force-enabled", true);