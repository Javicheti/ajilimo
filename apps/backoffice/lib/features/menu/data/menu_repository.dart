import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/menu_item.dart';

class MenuRepository {
  List<MenuCategory> seed() => <MenuCategory>[
        MenuCategory(
          name: 'Postres',
          incomplete: true,
          products: <MenuProduct>[
            MenuProduct(id: 'p1', name: 'Cheesecake Nutella', description: 'Torta a base de queso crema con base de galleta decorada, crema de avellanas y pecanas, porción personal.', price: 15, emoji: '🍰'),
            MenuProduct(id: 'p2', name: 'Torta de Chocolate', description: 'Trozos de torta de chocolate, fudge de chocolate, decorada con trozos de chocolate, porción personal.', price: 15, emoji: '🍫'),
            MenuProduct(id: 'p3', name: 'Derrumbado de Alfajor', description: 'Base de trozos de galleta de alfajor con manjar blanco, decorado con pequeños alfajores, porción personal.', price: 15, emoji: '🍪'),
            MenuProduct(id: 'p4', name: 'Pie de Limón', description: 'Torta con crema de limón, base de galleta, merengue, porción personal.', price: 15, emoji: '🍋'),
            MenuProduct(id: 'p5', name: 'Tres leches de Lúcuma', description: 'Bizcocho de vainilla bañado en salsa de 3 leches, con pulpa de lúcuma, decorado con chantilly y canela.', price: 15, emoji: '🥮'),
          ],
        ),
        MenuCategory(
          name: 'PROMOS',
          products: <MenuProduct>[
            MenuProduct(id: 'p6', name: 'Combo Familiar', description: '1 torta grande + 2 porciones + bebida 1.5L.', price: 55, emoji: '🎁'),
          ],
        ),
      ];
}

final Provider<MenuRepository> menuRepositoryProvider =
    Provider<MenuRepository>((ref) => MenuRepository());
