// Widget? _buildFloatingActionButton() {
//   // TODO: Return a FloatingActionButton if a rewarded ad is available
//   return (!QuizManager.instance.isHintUsed && _rewardedAd != null)
//       ? FloatingActionButton.extended(
//           onPressed: () {
//             showDialog(
//               context: context,
//               builder: (context) {
//                 return AlertDialog(
//                   title: Text('Need a hint?'),
//                   content: Text('Watch an Ad to get a hint!'),
//                   actions: [
//                     TextButton(
//                       child: Text('cancel'.toUpperCase()),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                     ),
//                     TextButton(
//                       child: Text('ok'.toUpperCase()),
//                       onPressed: () {
//                         Navigator.pop(context);
//                         _rewardedAd?.show(
//                           onUserEarnedReward: (_, reward) {
//                             QuizManager.instance.useHint();
//                           },
//                         );
//                       },
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//           label: Text('Hint'),
//           icon: Icon(Icons.card_giftcard),
//         )
//       : null;
// }