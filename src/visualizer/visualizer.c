#include "../common.h"
#include "../jive.h"

#include <pthread.h>

#include <stdio.h>
#include <sys/mman.h>

#define VIS_SHM_PATH "squeezelite"
#define VIS_BUF_SIZE 16384

typedef enum { OUTPUT_OFF = -1, OUTPUT_STOPPED = 0, OUTPUT_BUFFER, OUTPUT_RUNNING,
		OUTPUT_PAUSE_FRAMES, OUTPUT_SKIP_FRAMES, OUTPUT_START_AT } output_state;

static struct vis_t {
	pthread_rwlock_t rwlock;
	unsigned buf_size;
	unsigned buf_index;
	output_state state;
	unsigned rate;
	char dummy[64];
	int16_t buffer[VIS_BUF_SIZE];
} * vis_mmap = NULL;

int vis_fd = -1;

void vis_lock(void) {
	pthread_rwlock_rdlock(&vis_mmap->rwlock);
}

void vis_unlock(void) {
	pthread_rwlock_unlock(&vis_mmap->rwlock);
}

bool vis_get_playing(void) {
	if (!vis_mmap) return false;
	return vis_mmap->state == OUTPUT_RUNNING ? true : false;
}

int16_t * vis_get_buffer(void) {
	return vis_mmap->buffer;
}

unsigned vis_get_buffer_len(void) {
	return vis_mmap->buf_size;
}

unsigned vis_get_buffer_idx(void) {
	return vis_mmap->buf_index;
}

extern int visualizer_spectrum_init(lua_State *L);
extern int visualizer_spectrum(lua_State *L);
extern int visualizer_vumeter(lua_State *L);

static const struct luaL_Reg visualizer_f[] = {
	{ "vumeter", visualizer_vumeter },
	{ "spectrum", visualizer_spectrum },
	{ "spectrum_init", visualizer_spectrum_init },
	{ NULL, NULL }
};

int luaopen_visualizer(lua_State *L) {
	lua_getglobal(L, "jive");

	/* register lua functions */
	lua_newtable(L);
	luaL_register(L, NULL, visualizer_f);
	lua_setfield(L, -2, "vis");

#ifdef WITH_SPPRIVATE
	luaopen_spprivate(L);
#endif

	return 0;
}

int vis_init(void) {

	vis_fd = shm_open(VIS_SHM_PATH, O_RDWR, 0777);
	if (vis_fd == -1) return -1;
	vis_mmap = mmap(NULL, sizeof(struct vis_t), PROT_READ | PROT_WRITE, MAP_SHARED, vis_fd, 0);
	if (vis_mmap == NULL) {
		shm_unlink(VIS_SHM_PATH);
		close(vis_fd);
		return -2;
	}

	return 0;
}

int vis_quit(void) {
	if (vis_mmap)
		munmap(vis_mmap, sizeof(struct vis_t));

	if (vis_fd != -1) {
		shm_unlink(VIS_SHM_PATH);
		close(vis_fd);
	}

	return 0;
}
