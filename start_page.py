import pygame
import sys

# Colors
BLACK = (32, 32, 32)
WHITE = (255, 255, 255)

def start_screen(screen, screen_width, screen_height):
    """Displays the start screen."""
    # Fonts
    font = pygame.font.Font(None, 60)

    title_text = font.render("2D Running Game", True, WHITE)
    title_rect = title_text.get_rect(center=(screen_width // 2, screen_height // 2 - 50))
    
    start_text = font.render("Press any key to start", True, WHITE)
    start_rect = start_text.get_rect(center=(screen_width // 2, screen_height // 2 + 50))
    
    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN:
                # Exit the start screen
                running = False

        # Clear the screen
        screen.fill(BLACK)

        # Draw text
        screen.blit(title_text, title_rect)
        screen.blit(start_text, start_rect)

        # Update the display
        pygame.display.flip()
