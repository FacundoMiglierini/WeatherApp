import 'package:flutter/material.dart';

class TitleCard extends StatelessWidget {
  const TitleCard({
    super.key,
  });


  double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = deviceWidth(context) > 1000 ? theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onBackground,
      fontWeight: FontWeight.bold, 
    ) : theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onBackground,
      fontWeight: FontWeight.bold, 
    );

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Weather App!',
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}