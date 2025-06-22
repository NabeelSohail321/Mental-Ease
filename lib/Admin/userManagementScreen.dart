import 'package:flutter/material.dart';
import 'package:mental_ease/Admin/providers/UserManagementProvider.dart';
import 'package:provider/provider.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late UserManagementProvider _provider;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _provider = UserManagementProvider();
    _provider.fetchUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _provider.setSearchQuery(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserManagementProvider>.value(
      value: _provider,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return PreferredSize(
      preferredSize: Size.fromHeight(isSmallScreen ? size.height * 0.16 : size.height * 0.2),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(isSmallScreen ? size.height * 0.02 : size.height * 0.03),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? size.width * 0.03 : size.width * 0.05,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'User ',
                          style: TextStyle(
                            color: Color(0xFF006064),
                            fontSize: isSmallScreen ? size.height * 0.025 : size.height * 0.035,
                            fontWeight: FontWeight.bold,
                            fontFamily: "CustomFont",
                          ),
                        ),
                        TextSpan(
                          text: 'Management',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: isSmallScreen ? size.height * 0.025 : size.height * 0.035,
                            fontWeight: FontWeight.bold,
                            fontFamily: "CustomFont",
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? size.height * 0.005 : size.height * 0.01),
                  Divider(
                    thickness: 2,
                    indent: isSmallScreen ? 30 : 50,
                    endIndent: isSmallScreen ? 30 : 50,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Consumer<UserManagementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.users.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              ),
            ),
          );
        }

        return Column(
          children: [
            _buildSearchField(context),
            _buildFilterChips(context),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 16,
                ),
                child: ListView.builder(
                  itemCount: provider.filteredUsers.length,
                  itemBuilder: (context, index) {
                    return _buildUserCard(context, provider.filteredUsers[index]);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by username or email...',
          prefixIcon: Icon(Icons.search, size: isSmallScreen ? 20 : 24),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, size: isSmallScreen ? 20 : 24),
            onPressed: () {
              _searchController.clear();
              Provider.of<UserManagementProvider>(context, listen: false)
                  .setSearchQuery('');
              FocusScope.of(context).unfocus();
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 20),
            borderSide: BorderSide(color: Color(0xFF80DEEA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 20),
            borderSide: BorderSide(color: Color(0xFF80DEEA), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? size.height * 0.008 : size.height * 0.01,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final provider = Provider.of<UserManagementProvider>(context);

    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Admins', 'value': 'admins'},
      {'label': 'Users', 'value': 'users'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 6 : 8,
        horizontal: isSmallScreen ? 12 : 16,
      ),
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 3 : 4),
            child: FilterChip(
              label: Text(
                filter['label']!,
                style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
              ),
              selected: provider.currentFilter == filter['value'],
              onSelected: (selected) {
                provider.setFilter(filter['value']!);
              },
              selectedColor: Color(0xFF80DEEA),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: provider.currentFilter == filter['value']
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AppUser user) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isAdmin = user.role == 'Admin';

    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? size.height * 0.01 : size.height * 0.015),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? size.width * 0.03 : size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username ?? 'No username',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006064),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        user.email ?? 'No email',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Chip(
                  labelPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 4 : 6,
                  ),
                  label: Text(
                    user.role,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                  backgroundColor: isAdmin ? Colors.blue : Colors.green,
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: isSmallScreen ? size.width * 0.4 : size.width * 0.35,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAdmin ? Colors.red[400] : Color(0xFF80DEEA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 20),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? size.height * 0.01 : size.height * 0.012,
                    ),
                  ),
                  onPressed: () async {
                    try {
                      await Provider.of<UserManagementProvider>(context, listen: false)
                          .toggleAdminRole(user.id, user.role);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isAdmin
                                ? 'User admin privileges removed'
                                : 'User promoted to admin',
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                        ),
                      );
                    }
                  },
                  child: Text(
                    isAdmin ? 'Remove Admin' : 'Make Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}