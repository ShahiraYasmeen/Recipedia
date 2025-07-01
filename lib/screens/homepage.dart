import 'package:flutter/material.dart';
import 'recipe_detail_page.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  int indexx = 0;
  List category = ['Favourite', 'Appetizer', 'Main Course', 'Dessert', 'Beverages', 'Snacks'];
  List categoryname = ['App', 'MC', 'Dess', 'Bev', 'Sna'];
  List foodname = [
    ['Salmon Toast', 'Cheese Bites', 'Spring Rolls', 'Mini Quiche'],
    ['Grilled Chicken', 'Chicken Curry', 'Beef Stew', 'Seafood Pasta'],
    ['Strawberry Tart', 'Lava Cake', 'Berry Tart', 'Cheesecake'],
    ['Mojito', 'Lemonade', 'Iced Coffee', 'Smoothie'],
    ['Nachos', 'Popcorn', 'Chips', 'Nuggets'],
  ];

  // Track favorites: List per category, each with 4 booleans
  List<List<bool>> isFavorite = List.generate(5, (_) => List.filled(4, false));

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> favoriteItems = [];

    if (indexx == 0) {
      for (int cat = 0; cat < isFavorite.length; cat++) {
        for (int i = 0; i < isFavorite[cat].length; i++) {
          if (isFavorite[cat][i]) {
            favoriteItems.add({
              'title': foodname[cat][i],
              'image': 'assets/${categoryname[cat]}$i.jpg',
              'catIndex': cat,
              'foodIndex': i,
            });
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Recipedia',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Color(0xFF8B0000),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Text(
                'Popular Category',
                style: TextStyle(fontSize: 20, color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      itemCount: category.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                indexx = index;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: indexx == index ? Color(0xFF8B0000) : Colors.transparent,
                                boxShadow: [
                                  BoxShadow(
                                    color: indexx == index ? Color(0xFF8B0000) : Colors.transparent,
                                    offset: indexx == index ? Offset(1, 1) : Offset(0, 0),
                                    blurRadius: indexx == index ? 7 : 0,
                                  )
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
                                child: Center(
                                  child: Text(
                                    category[index],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: indexx == index ? Colors.white : Colors.black,
                                      fontFamily: 'roboto',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: const [
                      Text(
                        'Recipes',
                        style: TextStyle(fontSize: 20, color: Colors.black, fontFamily: 'roboto'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Get correct indexes based on category
                  int catIndex = indexx == 0 ? favoriteItems[index]['catIndex'] : indexx - 1;
                  int foodIndex = indexx == 0 ? favoriteItems[index]['foodIndex'] : index;
                  String title = foodname[catIndex][foodIndex];
                  String imagePath = 'assets/${categoryname[catIndex]}$foodIndex.jpg';

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.grey, blurRadius: 15, offset: Offset(1, 1)),
                      ],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isFavorite[catIndex][foodIndex] ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite[catIndex][foodIndex] ? Colors.red : Colors.black,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isFavorite[catIndex][foodIndex] = !isFavorite[catIndex][foodIndex];
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          child: Container(
                            height: 120,
                            width: 129,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(imagePath), 
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                          Navigator.push(
                            context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailPage(
                            title: foodname[indexx][index],
                            imagePath: 'assets/${categoryname[indexx]}$index.jpg',
                            ),
                          ),
                          );
                          },
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontFamily: 'roboto',
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: indexx == 0 ? favoriteItems.length : 4,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 270,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
            ),
          )
        ],
      ),
    );
  }
}
