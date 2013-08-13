extern int vis_init(void);
extern int vis_quit(void);

extern void vis_lock(void);
extern void vis_unlock(void);

extern bool vis_get_playing(void);
extern void vis_get_mac(char * mac);
extern u32_t vis_get_rate(void);

extern int16_t * vis_get_buffer(void);
extern u16_t vis_get_buffer_len(void);
extern u16_t vis_get_buffer_idx(void);
