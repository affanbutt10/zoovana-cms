import '../../features/shop/data/datasources/shop_remote_datasource.dart';
import '../../features/shop/data/models/branch_model.dart';
import '../../features/shop/data/models/business_with_branches_model.dart';

/// Mock implementation of [ShopRemoteDataSource] for UI testing.
///
/// Returns instant success responses without hitting any network.
class MockShopRemoteDataSource implements ShopRemoteDataSource {
  @override
  Future<BusinessWithBranchesModel> getBusinessWithBranches() async {
    await Future.delayed(const Duration(milliseconds: 700));

    return BusinessWithBranchesModel.fromJson({
      'id': 'biz-001',
      'name': 'Zoovana Pet Store',
      'owner_id': 'mock-user-001',
      'tenant_id': 'tenant-001',
      'status': 'active',
      'created_at': '2024-01-15T10:00:00.000Z',
      'branches': [
        {
          'id': 'branch-001',
          'business_id': 'biz-001',
          'name': 'Main Branch - Riyadh',
          'address': 'King Fahd Road, Riyadh',
          'is_active': true,
          'created_at': '2024-01-15T10:00:00.000Z',
        },
        {
          'id': 'branch-002',
          'business_id': 'biz-001',
          'name': 'Jeddah Branch',
          'address': 'Tahlia Street, Jeddah',
          'is_active': true,
          'created_at': '2024-02-01T10:00:00.000Z',
        },
      ],
    });
  }

  @override
  Future<List<BranchModel>> getBranches() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return [
      BranchModel.fromJson({
        'id': 'branch-001',
        'business_id': 'biz-001',
        'name': 'Main Branch - Riyadh',
        'address': 'King Fahd Road, Riyadh',
        'is_active': true,
        'created_at': '2024-01-15T10:00:00.000Z',
      }),
      BranchModel.fromJson({
        'id': 'branch-002',
        'business_id': 'biz-001',
        'name': 'Jeddah Branch',
        'address': 'Tahlia Street, Jeddah',
        'is_active': true,
        'created_at': '2024-02-01T10:00:00.000Z',
      }),
    ];
  }
}
