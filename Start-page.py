import pygame

# Initialize Pygame
pygame.init()

# Set screen dimensions
screen_width = 800
screen_height = 600
screen = pygame.display.set_mode((screen_width, screen_height))

# Set title
pygame.display.set_caption("Start Page")

# Colors
black = (0, 0, 0)
white = (255, 255, 255)

# Fonts
font = pygame.font.Font(None, 60)

# Text
title_text = font.render("My Game", True, white)
title_rect = title_text.get_rect(center=(screen_width // 2, screen_height // 2 - 50))

start_text = font.render("Press any key to start", True, white)
start_rect = start_text.get_rect(center=(screen_width // 2, screen_height // 2 + 50))

# Main loop
running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        if event.type == pygame.KEYDOWN:
            # Start the game or go to the next screen
            running = False

    # Clear the screen
    screen.fill(black)

    # Draw text
    screen.blit(title_text, title_rect)
    screen.blit(start_text, start_rect)

    # Update the display
    pygame.display.flip()

# Quit Pygame
pygame.quit()