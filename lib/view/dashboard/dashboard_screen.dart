import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/color.dart';
import 'package:tech_media/view/dashboard/profile/profile_screen.dart';
import 'package:tech_media/view/dashboard/user/user_screen.dart';
import '../group_chats/group_chat_screen.dart';
import 'Home/HomeScreen.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {

  final controller = PersistentTabController(initialIndex: 0);

  /// List of screens
  List<Widget>  _screens(){
    return [
      HomeScreen(),
      const Center(child: Text('data')),
      const GroupChatHomeScreen(),
      const ProfileScreen()
    ];
  }
   List<PersistentBottomNavBarItem> _navbarItem(){
    return [
      PersistentBottomNavBarItem(
        icon: const FaIcon(FontAwesomeIcons.userPlus,size: 22),
        activeColorPrimary: AppColors.secondaryTealColors,
        inactiveIcon: FaIcon(FontAwesomeIcons.userPlus, size: 20,color: Colors.grey.shade100)
      ),
      PersistentBottomNavBarItem(
          icon: const FaIcon(FontAwesomeIcons.solidCommentDots,),
          activeColorPrimary:AppColors.secondaryTealColors,
          inactiveIcon: FaIcon(FontAwesomeIcons.solidCommentDots, color: Colors.grey.shade100)
      ),
      PersistentBottomNavBarItem(
          icon: const FaIcon(FontAwesomeIcons.userFriends,size: 22),
          activeColorPrimary:AppColors.secondaryTealColors,
          inactiveIcon: FaIcon(FontAwesomeIcons.userFriends,size: 20, color: Colors.grey.shade100)
      ),
      PersistentBottomNavBarItem(
          icon: const FaIcon(FontAwesomeIcons.gear,),
          activeColorPrimary:AppColors.secondaryTealColors,
          inactiveIcon: FaIcon(FontAwesomeIcons.gear, color: Colors.grey.shade100)
      ),
    ];
   }


  @override
  Widget build(BuildContext context) {
    return  PersistentTabView(
        context,
        screens: _screens(),
        items: _navbarItem(),
      padding: const NavBarPadding.only(top: 20,bottom: 8),
      backgroundColor: AppColors.dividedColor,
      controller: controller,
      navBarStyle: NavBarStyle.style14,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      stateManagement: true,
      navBarHeight: 70,
    );
  }
}



// Scaffold(
// appBar: AppBar(elevation: 1,
// actions: [
// IconButton(icon: Icon(Icons.logout),
// onPressed: () {
// SessionController().userId = '';
// Navigator.pushNamed(context, RouteName.loginView);
// },),
// SizedBox(height: 10),
// ],
// ),
// body: Column(children: [],),
// );