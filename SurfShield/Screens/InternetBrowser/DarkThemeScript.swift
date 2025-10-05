//
//  File.swift
//  SurfShield
//
//  Created by Артур Кулик on 05.10.2025.
//

import Foundation

class DarkThemeScript {
    
    /// Возвращает JavaScript код для белого текста и черных фонов
    func getDarkThemeScript() -> String {
        return """
        (function() {
            'use strict';

            console.log('🎨 SurfShield: Запуск упрощенного скрипта темной темы...');

            // Функция для проверки, светлый ли цвет
            function isLightColor(color) {
                if (!color || color === 'transparent' || color === 'rgba(0, 0, 0, 0)') {
                    return false;
                }
                
                const rgbMatch = color.match(/rgba?\\((\\d+),\\s*(\\d+),\\s*(\\d+)/);
                if (!rgbMatch) return false;
                
                const r = parseInt(rgbMatch[1], 10);
                const g = parseInt(rgbMatch[2], 10);
                const b = parseInt(rgbMatch[3], 10);

                // Вычисляем яркость (luminance)
                const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;

                // Считаем цвет светлым, если яркость больше 0.85 (85%) - более консервативно
                return luminance > 0.85;
            }

            // Применяем темную тему к фону, сохраняя цвет текста
            function applyDarkTheme() {
                document.querySelectorAll('*').forEach(el => {
        
        
                    const style = getComputedStyle(el);

                    if (style.backgroundColor && isLightColor(style.backgroundColor)) {
                        el.style.setProperty('background-color', 'transparent', 'important');
                    }

                    if (style.borderColor && isLightColor(style.borderColor)) {
                        el.style.setProperty('border-color', 'white', 'important');
                    }

                    if (!isLightColor(style.color)) {
                        el.style.setProperty('color', 'white', 'important');
                    }
                });

                // Общий фон и текст на body/html
                if (document.body) {
                    document.body.style.setProperty('background-color', '#0F0F10', 'important');
                    document.body.style.setProperty('color', 'white', 'important');
                }
                if (document.documentElement) {
                    document.documentElement.style.setProperty('background-color', '#0F0F10', 'important');
                    document.documentElement.style.setProperty('color', 'white', 'important');
                }

                console.log('✅ SurfShield: Темная тема применена, включая верхние слои');
            }


            // Применяем мгновенно
            applyDarkTheme();
            
            // Применяем при загрузке DOM
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', function() {
                    applyDarkTheme();
                });
            }
            
            // Применяем при полной загрузке
            window.addEventListener('load', function() {
                applyDarkTheme();
            });
            
            // Применяем при изменении DOM (для динамического контента)
            if (window.MutationObserver) {
                const observer = new MutationObserver(function(mutations) {
                    mutations.forEach(function(mutation) {
                        if (mutation.type === 'childList') {
                            mutation.addedNodes.forEach(function(node) {
                                if (node.nodeType === 1) { // Element node
                                    // Применяем темную тему к новому элементу
                                    const style = getComputedStyle(node);
                                    
                                    if (style.backgroundColor && isLightColor(style.backgroundColor)) {
                                        node.style.setProperty('background-color', 'transparent', 'important');
                                    }
                                    
                                    if (style.borderColor && isLightColor(style.borderColor)) {
                                        node.style.setProperty('border-color', 'white', 'important');
                                    }
                                    
                                    if (!isLightColor(style.color)) {
                                        node.style.setProperty('color', 'white', 'important');
                                    }
                                    
                                    // Применяем к дочерним элементам
                                    const children = node.querySelectorAll('*');
                                    children.forEach(function(child) {
                                        const childStyle = getComputedStyle(child);
                                        
                                        if (childStyle.backgroundColor && isLightColor(childStyle.backgroundColor)) {
                                            child.style.setProperty('background-color', 'transparent', 'important');
                                        }
                                        
                                        if (childStyle.borderColor && isLightColor(childStyle.borderColor)) {
                                            child.style.setProperty('border-color', 'white', 'important');
                                        }
                                        
                                        if (!isLightColor(childStyle.color)) {
                                            child.style.setProperty('color', 'white', 'important');
                                        }
                                    });
                                }
                            });
                        }
                    });
                });
                
                observer.observe(document.body || document.documentElement, {
                    childList: true,
                    subtree: true
                });
            }
            
            console.log('SurfShield: Темная тема применена МГНОВЕННО');

            // Применять повторно при динамических изменениях и скролле можно дополнительно
        })();

        """
    }
}
