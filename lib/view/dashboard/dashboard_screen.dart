import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:tech_media/res/color.dart';
import 'package:tech_media/view/dashboard/profile/profile_screen.dart';
import 'package:tech_media/view/dashboard/user/user_screen.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {

  final controller = PersistentTabController(initialIndex: 0);

  List<Widget>  _screens(){
    return [
      Center(child: Text('data')),
      Center(child: Text('data')),
      Center(child: Text('data')),
      AllUserScreen(),
      ProfileScreen()
    ];
  }
   List<PersistentBottomNavBarItem> _navbarItem(){
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home,),
        activeColorPrimary: AppColors.primaryIconColor,
        inactiveIcon: Icon(Icons.home, color: Colors.grey.shade100)
      ),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.sms,),
          activeColorPrimary:AppColors.primaryIconColor,
          inactiveIcon: Icon(Icons.sms_rounded, color: Colors.grey.shade100)
      ),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.add,),
          activeColorPrimary:AppColors.hintColor,
          inactiveIcon: Icon(Icons.add, color: AppColors.whiteColor),
        activeColorSecondary: AppColors.primaryIconColor
      ),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.add_box,),
          activeColorPrimary:AppColors.primaryIconColor,
          inactiveIcon: Icon(Icons.add_box, color: Colors.grey.shade100)
      ),
      PersistentBottomNavBarItem(
          icon: Icon(Icons.person,),
          activeColorPrimary:AppColors.primaryIconColor,
          inactiveIcon: Icon(Icons.person, color: Colors.grey.shade100)
      ),
    ];
   }


  @override
  Widget build(BuildContext context) {
    return  PersistentTabView(
        context,
        screens: _screens(),
        items: _navbarItem(),
      backgroundColor: AppColors.otpHintColor,
      controller: controller,
      navBarStyle: NavBarStyle.style15,
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(1)
      ),
      stateManagement: true,
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