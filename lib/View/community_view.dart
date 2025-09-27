import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/community_controller.dart';
import 'Widget/Community/post_card_widget.dart';
import 'Widget/community_stat_item.dart';

class CommunityView extends GetView<CommunityController> {
  static String route = '/community';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('커뮤니티', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // 검색 화면으로 이동
              },
            ),
          ),
        ],
        bottom: TabBar(
          controller: controller.tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: [
            Tab(icon: Icon(Icons.home_outlined), text: '홈'),
            Tab(icon: Icon(Icons.group_outlined), text: '내 게시글'),
          ],
        ),
      ),
      body: TabBarView(controller: controller.tabController, children: [_buildHomeTab(), _buildMyCommunityTab()]),
      floatingActionButton: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 맨 위로 가기 버튼
            if (controller.showScrollToTop.value)
              Container(
                margin: EdgeInsets.only(bottom: Get.size.height * 0.01),
                child: FloatingActionButton(
                  mini: true,
                  heroTag: "scrollToTop",
                  onPressed: controller.scrollToTop,
                  backgroundColor: Colors.grey[600],
                  child: Icon(Icons.keyboard_arrow_up, color: Colors.white),
                ),
              ),
            // 게시글 추가 버튼
            FloatingActionButton(heroTag: "addPost", onPressed: () => _showCreateOptions(context), child: Icon(Icons.add), backgroundColor: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }

  // 홈 탭
  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: CustomScrollView(
        controller: controller.scrollController,
        slivers: [
          // 참여 중인 커뮤니티 슬라이더
          SliverToBoxAdapter(
            child: Container(
              height: Get.size.height * 0.18,
              padding: EdgeInsets.symmetric(vertical: Get.size.height * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Get.size.width * 0.04),
                    child: Text(
                      '내 커뮤니티',
                      style: TextStyle(fontSize: Get.size.width * 0.045, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: Get.size.height * 0.015),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: Get.size.width * 0.04),
                      itemCount: controller.categories.length,
                      itemBuilder: (context, index) => _buildCommunityItem(index),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 선택된 커뮤니티에 따른 콘텐츠 표시
          Obx(
            () => controller.selectedCommunityIndex.value == null
                ? SliverToBoxAdapter(
                    child: Container(
                      height: Get.size.height * 0.5,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group_outlined, size: Get.size.width * 0.2, color: Colors.grey[400]),
                            SizedBox(height: Get.size.height * 0.02),
                            Text(
                              '커뮤니티를 선택해주세요',
                              style: TextStyle(fontSize: Get.size.width * 0.045, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                            ),
                            SizedBox(height: Get.size.height * 0.01),
                            Text(
                              '위에서 관심있는 커뮤니티를 선택하면\n해당 커뮤니티의 게시글을 볼 수 있어요',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: Get.size.width * 0.035, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(delegate: SliverChildBuilderDelegate((context, index) => buildPostCard(index), childCount: 20)),
          ),
        ],
      ),
    );
  }

  // 커뮤니티 아이템 위젯
  Widget _buildCommunityItem(int index) {
    return Obx(() {
      bool isSelected = controller.selectedCommunityIndex.value == index;

      return InkWell(
        onTap: () => controller.selectCommunity(index),
        borderRadius: BorderRadius.circular(Get.size.width * 0.02),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: Get.size.width * 0.175,
          margin: EdgeInsets.only(right: Get.size.width * 0.03),
          padding: EdgeInsets.all(Get.size.width * 0.01),
          decoration: BoxDecoration(
            color: isSelected ? Get.theme.primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(Get.size.width * 0.02),
            border: isSelected ? Border.all(color: Get.theme.primaryColor, width: 2) : null,
          ),
          child: Column(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                child: CircleAvatar(
                  radius: Get.size.width * 0.0625,
                  backgroundColor: isSelected ? Get.theme.primaryColor : Colors.grey[300],
                  child: Text(
                    controller.categories[index].name.substring(0, 1),
                    style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                  ),
                ),
              ),
              SizedBox(height: Get.size.height * 0.007),
              Text(
                controller.categories[index].name,
                style: TextStyle(
                  fontSize: Get.size.width * 0.0275,
                  color: isSelected ? Get.theme.primaryColor : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    });
  }

  // 내 커뮤니티 탭
  Widget _buildMyCommunityTab() {
    return Column(
      children: [
        // 통계 카드
        Container(
          margin: EdgeInsets.all(Get.size.width * 0.04),
          padding: EdgeInsets.all(Get.size.width * 0.05),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue[400]!, Colors.blue[600]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(Get.size.width * 0.0375),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [buildStatItem('참여 중', '12', Icons.group), buildStatItem('내 게시글', '45', Icons.post_add), buildStatItem('받은 좋아요', '128', Icons.favorite)],
          ),
        ),
        // 참여 중인 커뮤니티 리스트
        Expanded(child: ListView.builder(itemCount: 12, itemBuilder: (context, index) => _buildMyCommunityTile(index))),
      ],
    );
  }

  // 내 커뮤니티 타일
  Widget _buildMyCommunityTile(int index) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: Get.size.width * 0.04, vertical: Get.size.height * 0.005),
      child: ListTile(
        title: Text('내 커뮤니티 ${index + 1}'),
        subtitle: Text('멤버 ${(index + 1) * 50}명 • 새 게시글 ${index + 2}개'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: Get.size.width * 0.02),
            Icon(Icons.arrow_forward_ios, size: Get.size.width * 0.04),
          ],
        ),
        onTap: () {
          // 커뮤니티 상세 화면으로 이동
        },
      ),
    );
  }

  // 생성 옵션 모달
  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Get.size.width * 0.05))),
      builder: (context) => Container(
        padding: EdgeInsets.all(Get.size.width * 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Get.size.width * 0.1,
              height: Get.size.height * 0.005,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(Get.size.width * 0.005)),
            ),
            SizedBox(height: Get.size.height * 0.025),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(Get.size.width * 0.02),
                decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(Get.size.width * 0.02)),
                child: Icon(Icons.post_add, color: Colors.blue),
              ),
              title: Text('게시글 작성'),
              subtitle: Text('커뮤니티에 새 게시글을 작성하세요'),
              onTap: () {
                Navigator.pop(context);
                controller.createPost();
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(Get.size.width * 0.02),
                decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(Get.size.width * 0.02)),
                child: Icon(Icons.group_add, color: Colors.green),
              ),
              title: Text('커뮤니티 만들기'),
              subtitle: Text('새로운 커뮤니티를 만들어보세요'),
              onTap: () {
                Navigator.pop(context);
                controller.createCommunity();
              },
            ),
            SizedBox(height: Get.size.height * 0.025),
          ],
        ),
      ),
    );
  }
}
