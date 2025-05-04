import pygame
import sys
import random
import os
# Importing from folders
from screens.start_screen import start_screen
from screens.controls_screen import controls_screen
from screens.name_input_screen import name_input_screen
from screens.game_over_screen import game_over_screen
from screens.thanks_for_playing_screen import thanks_for_playing_screen 


def set_working_directory():
    if getattr(sys, 'frozen', False):
        working_dir = sys._MEIPASS
    else:
        working_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(working_dir)

set_working_directory()
pygame.init()
os.chdir(os.path.dirname(__file__))
pygame.mixer.init()
pygame.mixer.music.load("music/running-game-music.mp3")
pygame.mixer.music.set_volume(0.6)
pygame.mixer.music.play(-1)

coin_sound = pygame.mixer.Sound("music/coin-get.mp3")
coin_sound.set_volume(0.3)

skull_sound = pygame.mixer.Sound("music/skull-sound.wav")
skull_sound.set_volume(0.3)

def load_image(filename):
    if getattr(sys, 'frozen', False):
        base_path = sys._MEIPASS
    else:
        base_path = os.path.dirname(__file__)
    full_path = os.path.join(base_path, filename)
    if not os.path.exists(full_path):
        raise FileNotFoundError(f"Image not found: {full_path}")
    return pygame.image.load(full_path).convert_alpha()

def play_coin_sound():
    pygame.mixer.music.set_volume(0.5)
    coin_sound.play()

def play_skull_sound():
    pygame.mixer.music.set_volume(0.5)
    skull_sound.play()

SCREEN_WIDTH, SCREEN_HEIGHT = 900, 500
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("2D Running Game")
WHITE, BLACK, RED, GREEN = (255, 255, 255), (32, 32, 32), (255, 0, 0), (0, 255, 0)
GROUND_Y, clock = 425, pygame.time.Clock()

font = pygame.font.Font(None, 36)
large_font = pygame.font.Font(None, 55)
extra_large_font = pygame.font.Font(None, 70)

class Player(pygame.sprite.Sprite):
    def __init__(self, x, y, width, height, name):
        super().__init__()
        self.run_frames = [load_image(f'running-game-animations/player/running/frame-{i}.png') for i in range(1, 7)]
        self.run_frames = [pygame.transform.scale(frame, (width, height + 30)) for frame in self.run_frames]
        self.idle_frames = [load_image(f'running-game-animations/player/idle/frame-{i}.png') for i in range(1, 3)]
        self.idle_frames = [pygame.transform.scale(frame, (width + 4, height + 30)) for frame in self.idle_frames]
        self.jump_up_frame = load_image("running-game-animations/player/jump/jump-up.png")
        self.jump_fall_frame = load_image("running-game-animations/player/jump/jump-fall.png")
        self.jump_up_frame = pygame.transform.scale(self.jump_up_frame, (width + 6, height + 30))
        self.jump_fall_frame = pygame.transform.scale(self.jump_fall_frame, (width + 8, height + 30))
        self.life_icon = load_image("running-game-animations/player/lives/lives.png")
        self.life_icon = pygame.transform.scale(self.life_icon, (30, 30))

        self.current_frame = 0
        self.image = self.idle_frames[self.current_frame]
        self.rect = self.image.get_rect(topleft=(x, y))
        self.x_velocity, self.y_velocity = 0, 0
        self.jumping = False
        self.facing_right = True
        self.name = name
        self.lives = 5
        self.animation_speed = 5
        self.animation_counter = 0
        self.is_moving = False

    def update(self, controller):
        self.is_moving = False
        if controller["up"] and not self.jumping:
            self.y_velocity = -18
            self.jumping = True
        if controller["left"]:
            self.x_velocity = -5
            self.facing_right = False
            self.is_moving = True
        elif controller["right"]:
            self.x_velocity = 5
            self.facing_right = True
            self.is_moving = True

        self.rect.x += self.x_velocity
        self.rect.y += self.y_velocity
        self.y_velocity += 0.8
        self.x_velocity *= 0.95

        if self.rect.left < 0:
            self.rect.left = 0
        if self.rect.right > SCREEN_WIDTH:
            self.rect.right = SCREEN_WIDTH

        if self.rect.bottom > GROUND_Y:
            self.rect.bottom = GROUND_Y
            self.jumping = False
            self.y_velocity = 0

        self.animate()

    def animate(self):
        if self.jumping:
            self.image = self.jump_up_frame if self.y_velocity < 0 else self.jump_fall_frame
            if not self.facing_right:
                self.image = pygame.transform.flip(self.image, True, False)
        elif self.is_moving:
            self.animation_counter += 1
            if self.animation_counter >= self.animation_speed:
                self.animation_counter = 0
                self.current_frame = (self.current_frame + 1) % len(self.run_frames)
                self.image = pygame.transform.scale(self.run_frames[self.current_frame], self.rect.size)
                if not self.facing_right:
                    self.image = pygame.transform.flip(self.image, True, False)
        else:
            self.animation_counter += 1
            if self.animation_counter >= self.animation_speed * 2:
                self.animation_counter = 0
                self.current_frame = (self.current_frame + 1) % len(self.idle_frames)
                self.image = pygame.transform.scale(self.idle_frames[self.current_frame], self.rect.size)
                if not self.facing_right:
                    self.image = pygame.transform.flip(self.image, True, False)

    def respawn(self):
        self.rect.x, self.rect.y = 50, -50
        self.x_velocity, self.y_velocity = 0, 0
        self.jumping = True

    def draw(self, screen):
        screen.blit(self.image, self.rect.topleft)
        name_surface = font.render(self.name, True, BLACK)
        screen.blit(name_surface, name_surface.get_rect(center=(self.rect.centerx, self.rect.top - 10)))

class Obstacle(pygame.sprite.Sprite):
    """The obstacle class."""
    def __init__(self, x, y, width, height, speed):
        super().__init__()
        self.image = load_image('images/rock-obstacle.png')
        self.image = pygame.transform.scale(self.image, (width, height))
        self.rect = self.image.get_rect(topleft=(x, y))
        self.speed = speed

    def update(self):
        self.rect.x -= self.speed
        if self.rect.right < 0:
            self.kill()

class Coin(pygame.sprite.Sprite):
    def __init__(self, x, y, width, height, speed):
        super().__init__()
        self.image = load_image('images/coins/coin.png')
        self.image = pygame.transform.scale(self.image, (width, height))
        self.rect = self.image.get_rect(topleft=(x, y))
        self.speed = speed

    def update(self):
        self.rect.x -= self.speed
        if self.rect.right < 0:
            self.kill()

class SuperCoin(pygame.sprite.Sprite):
    def __init__(self, x, y, width, height, speed):
        super().__init__()
        self.image = load_image('images/coins/super-coin.png')
        self.image = pygame.transform.scale(self.image, (width, height))
        self.rect = self.image.get_rect(topleft=(x, y))
        self.speed = speed

    def update(self):
        self.rect.x -= self.speed
        if self.rect.right < 0:
            self.kill()

class Sparkle(pygame.sprite.Sprite):
    def __init__(self, x, y, width, height):
        super().__init__()
        self.image = load_image('images/coins/coin-sparkle.png')
        self.image = pygame.transform.scale(self.image, (width, height))
        self.rect = self.image.get_rect(center=(x, y))
        self.lifetime = 15

    def update(self):
        self.lifetime -= 1
        if self.lifetime <= 0:
            self.kill()

class SkullEnemy(pygame.sprite.Sprite):
    def __init__(self, x, y, width, height, speed):
        super().__init__()
        self.frames = [load_image(f'running-game-animations/skull-biting-enemy/frame-{i}.png') for i in range(1, 12)]
        self.frames = [pygame.transform.scale(frame, (width, height)) for frame in self.frames]
        self.current_frame = 0
        self.image = self.frames[self.current_frame]
        self.rect = self.image.get_rect(topleft=(x, y))
        self.speed = speed
        self.animation_counter = 0
        self.animation_speed = 4

    def update(self):
        self.rect.x -= self.speed
        if self.rect.right < 0:
            self.kill()

        self.animation_counter += 1
        if self.animation_counter >= self.animation_speed:
            self.animation_counter = 0
            self.current_frame = (self.current_frame + 1) % len(self.frames)
            self.image = self.frames[self.current_frame]

# You can now add `skull_enemies = pygame.sprite.Group()` and spawn `SkullEnemy` in game_loop as needed.

def game_loop(player_name):
    """The main game loop."""
    mountain_bg = load_image("images/backgrounds/whole-background.jpg")
    mountain_bg = pygame.transform.scale(mountain_bg, (SCREEN_WIDTH, SCREEN_HEIGHT))
    bg_x1, bg_x2 = 0, SCREEN_WIDTH  # Positions for two background images to create a seamless loop

    player = Player(50, GROUND_Y - 50, 50, 50, name=player_name)
    all_sprites = pygame.sprite.Group(player)
    obstacles = pygame.sprite.Group()
    coins = pygame.sprite.Group()
    super_coins = pygame.sprite.Group()
    sparkles = pygame.sprite.Group()
    skull_enemies = pygame.sprite.Group()
    controller, obstacle_timer, spawn_interval, score, respawn_timer = {"left": False, "right": False, "up": False}, 0, 90, 0, 0
    last_score_time = pygame.time.get_ticks()  # Track the start time for score increment

    while player.lives > 0:
        screen.fill(WHITE)
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type in (pygame.KEYDOWN, pygame.KEYUP):
                key_state = event.type == pygame.KEYDOWN
                if event.key == pygame.K_LEFT:
                    controller["left"] = key_state
                elif event.key == pygame.K_RIGHT:
                    controller["right"] = key_state
                elif event.key == pygame.K_UP:
                    controller["up"] = key_state
                elif event.key == pygame.K_ESCAPE and key_state:
                    return
                
        # Scroll the background
        bg_x1 -= 2  # Adjust the speed of the scrolling
        bg_x2 -= 2
        if bg_x1 <= -SCREEN_WIDTH:
            bg_x1 = SCREEN_WIDTH
        if bg_x2 <= -SCREEN_WIDTH:
            bg_x2 = SCREEN_WIDTH

        # Draw the background
        screen.blit(mountain_bg, (bg_x1, 0))
        screen.blit(mountain_bg, (bg_x2, 0))

        # Update Sprites
        all_sprites.update(controller)
        obstacles.update()
        coins.update()
        super_coins.update()
        sparkles.update()
        skull_enemies.update()

        # Increment score every second
        current_time = pygame.time.get_ticks()
        if current_time - last_score_time >= 1000:  # Every 1000 ms (1 second)
            score += 100
            last_score_time = current_time

        if respawn_timer == 0:
            obstacle_timer += 1
            # Adjust spawn speed after reaching a score of 15,000
            if score >= 15000:
                spawn_interval = 60  # Faster obstacle spawn rate

            if obstacle_timer >= spawn_interval:
                obstacle_timer = 0
                obstacle_x = SCREEN_WIDTH + random.randint(0, 300)
                obstacle_y = GROUND_Y - 75
                coin_y = GROUND_Y - 175
                super_coin_y = GROUND_Y - 275
                
                if False:  # Prevent obstacle from being added
                    obstacles.add(Obstacle(obstacle_x, obstacle_y, 75, 75, speed=6))

                coins.add(Coin(obstacle_x, coin_y, 50, 50, speed=10))
                super_coins.add(SuperCoin(obstacle_x, super_coin_y, 50, 50, speed=3))

                # Add this line to spawn skull enemies every other spawn
                if random.random() < 0.5:
                    skull_enemies.add(SkullEnemy(obstacle_x + 150, obstacle_y, 75, 75, speed=5))
                    play_skull_sound()

        # Collision Effects
        if pygame.sprite.spritecollide(player, obstacles, False):
            player.respawn()
            player.lives -= 1
            respawn_timer = 180  # 3 second delay before spawning obstacles

        if pygame.sprite.spritecollide(player, coins, True):
            score += 100
            sparkles.add(Sparkle(player.rect.centerx, player.rect.top, 60, 60))
            play_coin_sound()
            
        if pygame.sprite.spritecollide(player, super_coins, True):
            score += 500
            # Bigger sparkle
            sparkles.add(Sparkle(player.rect.centerx, player.rect.top, 70, 70))
            play_coin_sound()

        if pygame.sprite.spritecollide(player, skull_enemies, True):
            player.respawn()
            player.lives -= 1
            respawn_timer = 180

        if respawn_timer > 0:
            respawn_timer -= 1

        # Draws everything
        all_sprites.draw(screen)
        player.draw(screen)
        # obstacles.draw(screen)
        coins.draw(screen)
        super_coins.draw(screen)
        sparkles.draw(screen)
        skull_enemies.draw(screen)

        # Display Lives in the Top Left Corner
        lives_text = font.render("Lives:", True, WHITE)
        pygame.draw.rect(screen, BLACK, (5, 5, 230, 35), border_radius=5) # Background for lives
        screen.blit(lives_text, (10, 10))  # Position "Lives:" text 

        # Draw life icons next to the text
        start_x = 80  # Adjust spacing
        for _ in range(player.lives):
            screen.blit(player.life_icon, (start_x, 7))
            start_x += 30  # Space out the icons
        screen.blit(font.render(f"Score: {score}", True, BLACK), (10, 40))
        pygame.display.flip()

        clock.tick(60) # Cap the frame rate

    pygame.mixer.music.stop() # Stops music

    thanks_for_playing_screen(screen, large_font, extra_large_font, score) # Thanks for playing screen
    game_over_screen(screen, font, large_font, player_name)
  
    # Restart game when user clicks restart
    pygame.mixer.music.load("music/running-game-music.mp3")  # Replace with your actual file name
    pygame.mixer.music.set_volume(0.6)  # Adjust volume (0.0 to 1.0)
    pygame.mixer.music.play(-1)  # Loop indefinitely

    game_loop(player.name)  # This will restart the game with

# Main game flow
start_screen(screen, large_font)
player_name = name_input_screen(screen, font)
controls_screen(screen)
if player_name:  # Only proceed if a valid name is entered
    game_loop(player_name)

