import vue from 'rollup-plugin-vue';
import peerDepsExternal from 'rollup-plugin-peer-deps-external';

export default [
  {
    plugins: [vue(), peerDepsExternal()],
  },
];
