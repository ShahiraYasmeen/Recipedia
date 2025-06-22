import 'package:flutter/material.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({Key? key}) : super(key: key);

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  int indexx = 0;
  List category = ['Appetizer', 'Main Course', 'Dessert', 'Beverages', 'Snacks'];
  List categoryname = ['App', 'MC', 'Dess', 'Bev', 'Sna'];
  List foodname = [
    ['Salmon Toast', 'Cheese Bites', 'Spring Rolls', 'Mini Quiche'],
    ['Chicken Curry', 'Beef Stew', 'Seafood Pasta', 'Grilled Salmon'],
    ['Lava Cake', 'Berry Tart', 'Cheesecake', 'Chocolate Mousse'],
    ['Mojito', 'Lemonade', 'Iced Coffee', 'Smoothie'],
    ['Nachos', 'Popcorn', 'Chips', 'Nuggets'],
  ];
  @override
  Widget build(BuildContext context) {
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
        backgroundColor:  Color(0xFF8B0000),
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
            padding: EdgeInsets.symmetric(horizontal: 15),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    height: 50,
                    child: ListView.builder(
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: ((context, index) {
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
                            color: indexx == index
                                  ? Color(0xFF8B0000)
                                  : Colors.transparent,
                            boxShadow: [
                              BoxShadow(
                                color: indexx == index 
                                  ? Color(0xFF8B0000)
                                  : Colors.transparent,
                                offset: indexx == index 
                                  ? Offset(1, 1) 
                                  : Offset(0, 0),
                                blurRadius: indexx == index ? 7 : 0,
                                )
                            ]),
                          child: Padding(
                            padding: 
                              const EdgeInsets.symmetric(
                                horizontal: 17,
                                vertical: 10),
                          child: Center(
                            child: Text(
                              category[index],
                              style: TextStyle(
                                fontSize: 16,
                                color: indexx == index?  Colors.white : Colors.black,
                                fontFamily: 'roboto',
                              )
                            )
                          )
                          ),
                        )
                      )
                        );
                      })
                    )
                  ),
                                SizedBox(height: 15),
                                Row(
                                children: [
                                Text(
                                  'Popular Recipes',
                                  style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontFamily: 'roboto',
                                  )
                                ),
                                ],
                                )
                 ],)
             )
          ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 15,
                            offset: Offset(1, 1), 
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [Icon(Icons.favorite_border)],
                          )
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,),
                            child: Container(
                            height: 120,
                            width: 129,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/${categoryname[indexx]}${index}.jpg'), 
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            )
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            foodname[indexx][index],
                            style: TextStyle(
                            fontSize: 18, 
                            color: Colors.black,
                            fontFamily: 'roboto',
                            ) 
                            ),
                        ],)
                    );
                  },
                  childCount: 4,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 270,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                )
              )
            )
        ]
            
  )
  );
}
}