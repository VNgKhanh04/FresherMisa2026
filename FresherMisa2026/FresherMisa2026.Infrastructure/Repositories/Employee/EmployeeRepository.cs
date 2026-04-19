using Dapper;
using FresherMisa2026.Application.Extensions;
using FresherMisa2026.Application.Interfaces.Repositories;
using FresherMisa2026.Entities.Employee;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;

namespace FresherMisa2026.Infrastructure.Repositories
{
    public class EmployeeRepository : BaseRepository<Employee>, IEmployeeRepository
    {
        public EmployeeRepository(IConfiguration configuration, IMemoryCache memoryCache) : base(configuration, memoryCache)
        {
        }

        public async Task<Employee> GetEmployeeByCode(string code)
        {
            string query = SQLExtension.GetQuery("Employee.GetByCode");
            var param = new Dictionary<string, object>
            {
                {"@EmployeeCode", code }
            };
            await using var connection = CreateConnection();
            await connection.OpenAsync();

            return await connection.QueryFirstOrDefaultAsync<Employee>(query, param, commandType: System.Data.CommandType.Text);
        }

        public async Task<IEnumerable<Employee>> GetEmployeesByDepartmentId(Guid departmentId)
        {
            string query = SQLExtension.GetQuery("Employee.GetByDepartmentId");
            var param = new Dictionary<string, object>
            {
                {"@DepartmentID", departmentId }
            };
            await using var connection = CreateConnection();
            await connection.OpenAsync();

            return await connection.QueryAsync<Employee>(query, param, commandType: System.Data.CommandType.Text);
        }

        public async Task<IEnumerable<Employee>> GetEmployeesByPositionId(Guid positionId)
        {
            string query = SQLExtension.GetQuery("Employee.GetByPositionId");
            var param = new Dictionary<string, object>
            {
                {"@PositionID", positionId }
            };
            await using var connection = CreateConnection();
            await connection.OpenAsync();

            return await connection.QueryAsync<Employee>(query, param, commandType: System.Data.CommandType.Text);
        }

        public async Task<IEnumerable<Employee>> GetEmployeesFilterAsync(
            Guid? departmentId,
            Guid? positionId,
            string? salaryFrom,
            string? salaryTo,
            int? gender,
            DateTime? hireDateFrom,
            DateTime? hireDateTo)
        {
            var param = new DynamicParameters();
            param.Add("v_DepartmentID", departmentId);
            param.Add("v_PositionID", positionId);

            param.Add("v_SalaryFrom", decimal.TryParse(salaryFrom, out var sf) ? sf : (decimal?)null);
            param.Add("v_SalaryTo", decimal.TryParse(salaryTo, out var st) ? st : (decimal?)null);

            param.Add("v_Gender", gender);
            param.Add("v_HireDateFrom", hireDateFrom?.Date);
            param.Add("v_HireDateTo", hireDateTo?.Date);

            await using var connection = CreateConnection();
            await connection.OpenAsync();

            return await connection.QueryAsync<Employee>("Proc_Employee_Filter", param, commandType: System.Data.CommandType.StoredProcedure);
        }
    }
}
