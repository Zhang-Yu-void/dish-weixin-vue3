<template>
  <div class="app-container home">
    <el-row :gutter="20">
      <el-col :sm="24" :lg="12" style="padding-left: 20px">
        <h2>若依后台管理框架</h2>
        <el-col :span="6">
          <h4>后端技术</h4>
          <ul>
            <li>SpringBoot</li>
            <li>Spring Security</li>
            <li>JWT</li>
            <li>MyBatis</li>
            <li>Druid</li>
            <li>Fastjson</li>
            <li>...</li>
          </ul>
        </el-col>
        <el-col :span="6">
          <h4>前端技术</h4>
          <ul>
            <li>Vue</li>
            <li>Vuex</li>
            <li>Element-ui</li>
            <li>Axios</li>
            <li>Sass</li>
            <li>Quill</li>
            <li>...</li>
          </ul>
        </el-col>
      </el-col>
    </el-row>
    <el-divider />
  </div>
</template>

<script setup lang="ts" name="Index"></script>

<style scoped lang="scss">
.home {
  blockquote {
    padding: 10px 20px;
    margin: 0 0 20px;
    font-size: 17.5px;
    border-left: 5px solid #eee;
  }
}
</style>
