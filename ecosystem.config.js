module.exports = {
  apps: [{
    name: 'taskboard',
    script: 'server.js',
    instances: 1,
    autorestart: true,
    env: {
      PORT: 3000,
      // 把下面引号里的空字符串改成你的 Token（字母数字组合，越长越安全，例如 8f3kD9s2）
      // 留空 = 不启用鉴权（仅适合内网/测试，公网部署务必设置）
      TASK_TOKEN: ''
    }
  }]
};
