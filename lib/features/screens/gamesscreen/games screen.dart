import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/custom_app_bar.dart';
import 'package:webedukid/utils/constants/colors.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Featured Games',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Placeholder for 5 games
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: Icon(Iconsax.game, color: MyColors.primaryColor),
                      title: Text('Game ${index + 1}'),
                      subtitle: Text('This is a description of Game ${index + 1}.'),
                      trailing: Icon(Iconsax.arrow_right, color: MyColors.primaryColor),
                      onTap: () {
                        // Handle game selection
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
