`ifndef MY_MONITOR__SV
`define MY_MONITOR__SV

// 定义一个名为 my_monitor 的类，继承自 uvm_monitor。
// uvm_monitor 是 UVM 框架中用于实现监视器功能的基类。
class my_monitor extends uvm_monitor;

   // 定义一个虚拟接口 vif，用于与测试平台中的接口连接。
   virtual my_if vif;

   // 使用 UVM 宏 `uvm_component_utils 注册该类，以便 UVM 框架能够识别和管理该类。
   // 这个宏会为类提供一些默认的方法，如打印、比较等。
   `uvm_component_utils(my_monitor)

   // 构造函数，用于创建 my_monitor 类的实例。
   // name 是实例的名称，默认值为 "my_monitor"。
   // parent 是父组件，默认值为 null。
   function new(string name = "my_monitor", uvm_component parent = null);
      super.new(name, parent); // 调用父类的构造函数完成初始化
   endfunction

   // 定义 build_phase 方法，这是 UVM 验证流程中的一个阶段。
   // 在这个阶段，组件可以进行一些初始化操作。
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase); // 调用父类的 build_phase 方法
      // 从配置数据库中获取虚拟接口 vif。
      // 如果获取失败，打印错误信息并终止验证。
      if(!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
         `uvm_fatal("my_monitor", "virtual interface must be set for vif!!!")
   endfunction

   // 声明两个外部任务，具体实现将在类外部定义。
   extern task main_phase(uvm_phase phase);
   extern task collect_one_pkt(my_transaction tr);
endclass

// 定义 main_phase 任务，这是监视器的主要任务，负责持续监视接口并收集数据。
task my_monitor::main_phase(uvm_phase phase);
   my_transaction tr; // 创建一个 my_transaction 类型的事务对象
   while(1) begin // 持续运行，不断收集数据
      tr = new("tr"); // 创建一个新的事务对象
      collect_one_pkt(tr); // 调用 collect_one_pkt 任务收集一个数据包
   end
endtask

// 定义 collect_one_pkt 任务，负责收集一个完整的数据包。
task my_monitor::collect_one_pkt(my_transaction tr);
   bit[7:0] data_q[$]; // 定义一个队列，用于存储从接口收集到的数据
   int psize; // 用于存储负载数据的大小

   // 等待 valid 信号变为高，表示数据有效。
   while(1) begin
      @(posedge vif.clk); // 等待时钟上升沿
      if(vif.valid) break; // 如果 valid 为高，退出循环
   end

   // 打印信息，表示开始收集一个数据包。
   `uvm_info("my_monitor", "begin to collect one pkt", UVM_LOW);
   // 当 valid 信号为高时，持续收集数据，直到 valid 变为低。
   while(vif.valid) begin
      data_q.push_back(vif.data); // 将数据存储到队列中
      @(posedge vif.clk); // 等待时钟上升沿
   end

   // 从队列中提取目的 MAC 地址（dmac），共 6 个字节。
   for(int i = 0; i < 6; i++) begin
      tr.dmac = {tr.dmac[39:0], data_q.pop_front()}; // 从队列前端取出一个字节并拼接到 dmac
   end
   // 从队列中提取源 MAC 地址（smac），共 6 个字节。
   for(int i = 0; i < 6; i++) begin
      tr.smac = {tr.smac[39:0], data_q.pop_front()}; // 从队列前端取出一个字节并拼接到 smac
   end
   // 从队列中提取以太网类型字段（ether_type），共 2 个字节。
   for(int i = 0; i < 2; i++) begin
      tr.ether_type = {tr.ether_type[7:0], data_q.pop_front()}; // 从队列前端取出一个字节并拼接到 ether_type
   end

   // 计算负载数据的大小，队列大小减去 4 个字节的 CRC。
   psize = data_q.size() - 4;
   tr.pload = new[psize]; // 分配负载数据数组
   // 从队列中提取负载数据。
   for(int i = 0; i < psize; i++) begin
      tr.pload[i] = data_q.pop_front(); // 从队列前端取出一个字节并存储到负载数据数组中
   end
   // 从队列中提取循环冗余校验码（crc），共 4 个字节。
   for(int i = 0; i < 4; i++) begin
      tr.crc = {tr.crc[23:0], data_q.pop_front()}; // 从队列前端取出一个字节并拼接到 crc
   end

   // 打印信息，表示结束收集一个数据包，并打印事务内容。
   `uvm_info("my_monitor", "end collect one pkt, print it:", UVM_LOW);
   tr.my_print(); // 调用事务对象的 my_print 方法打印事务内容
endtask

`endif // MY_MONITOR__SV
