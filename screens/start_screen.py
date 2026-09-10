import pygame
import sys
import math

def start_screen(screen, large_font):
    """Show the initial start screen with hovering title text."""
    pygame.init()
    
    start_text = large_font.render("Press any key to start", True, (255, 255, 255))
    title_image = pygame.image.load("images/title.png").convert_alpha()
    
    clock = pygame.time.Clock()
    start_time = pygame.time.get_ticks()  # Get the initial time

    while True:
        screen.fill((32, 32, 32))  # Clear the screen (optional)
        
        elapsed_time = pygame.time.get_ticks() - start_time  # Time since start
        hover_offset = int(math.sin(elapsed_time * 0.005) * 10)  # Smooth hover effect

        title_rect = title_image.get_rect(center=(screen.get_width() // 2, screen.get_height() // 2 - 20))
        screen.blit(title_image, title_rect)

        start_text_rect = start_text.get_rect(center=(screen.get_width() // 2 + 105, screen.get_height() // 2 + 110 + hover_offset))
        screen.blit(start_text, start_text_rect)

        pygame.display.flip()
        clock.tick(60)  # Limit frame rate

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            if event.type == pygame.KEYDOWN:
                return
