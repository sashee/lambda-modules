import {value} from "./dep.js";

const b = await (async () => {
	return 3 + value;
})();

export const handler = async (event) => {
	return "called from exported handler! value=" + b;
};
