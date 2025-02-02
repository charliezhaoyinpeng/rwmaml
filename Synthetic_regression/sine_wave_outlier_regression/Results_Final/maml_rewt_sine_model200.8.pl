��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_reweight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_reweight.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   2326743536368qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2326743539920qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2326743542128qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2326743539440q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2326743538384q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2326743539248q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2326743536368qX   2326743538384qX   2326743539248qX   2326743539440qX   2326743539920qX   2326743542128qe.(       ������>��=�?<���|�:��Dr����w�b�d̽>��s>� ?FG�<z���?�uN>4�+����=�TG��؂>���>Y�5�6��� "?#��=��E��cE�>����
d�k ?�=�*�>�M,?��>*N�A(�榪������(       �v�9��7AX?Ǭ���(�6T$�c�;?6Z�F=�>�U$)���?p�>z��O/�,��K�M?[چ=��>���� Y����=��;k�8�!=�c8��i�e.y?���>���>���c6޾��?�$|=��˾��>��?#H�>�c<<�ﶼ       ���(       s?�t�>���=��-?{��0��<a���J�>�(��+r?~S�����=�Kv�GP����Q?����g=i��r@��nc~���=>�V���?*�?<��p����<�>��x�����������I���r��g¾�K!?�-���	�������;d�!�(       ����Ȇ��z=H��>����P=,?��[Hܿ�0�M�����m<R���=�_��.?���бA��ͬ��?�E�<һ��W��H�e>Ί߿Q݅�������?�޿z�7�� ��p8�9-�>.H�]�� �?W	?�Խ ���\�M?�Î�@      ��g=\
����g/"��x��g< c�;�<y�:����J���R;c�	A����Ծ.e��&��"=�$�q�]��-�$�"�N�|7��LXd�S��Iµ�����2;E�>��	�>��=4f�>�[l�5��:	?�����Խ���� ��>wq�z�%\���>��>�/���=OZ�>s�=:f��Y�վ^&�9���=��>I�-����.�|�!�n����6b/>��#����}�=5H�������d�ҐZ>�:��²��t�̽~	�=S�о	��T��T���z,�MW>�.�B����?�r�׆�NL���w��	�G$M�u%,��9?���5�8d���� �&L�t�Z��=��>fٿ�A�Y>'�M�?�;�q?��=�-��
\� a����]��l�y���')/?�W6� ? =�T������c߼?v��>�X���;�v�ʾ����4�-�<?͈7>�S��B�<!YE?)�?-c�xr�=zŁ�_�9��<�������@l��%�(��=<A���FG�u�t���7[��ڽ�>e��ڄ���=m���~,¾_��Q�Ҿ�i(�.��=΄羿T�h�\����1Ҿ�m�?�?u!�=t�=�|����2��ڟ�vW�w5�����=_�G�m�#��;����J��p:���Ҿ�ʱ��L?���<|U����پ��̾ㄾ�U����;�R�"<��9���FG¾��㼽q���Z�罿�H�|�앳?y>=!�l����+^��^��s��1� ?&1e��򜻩T2�Zq��W܂=Yˌ��*���:��#���H�=D�#��;J�����>�ʖ>��^�h	�/i=i��kM�>������=~=Vx����9<}�;</׾)>�>�@����޽A
H>�ξ&C��aþV<�Q�m�2�>->l�A>O@?j_��+���Ȁp>�C�?��X��Q�=���Y�ݾ��Ƚ��q����>�Eڽ�ۇ>H�>DN��0?�S�>YV��.�=R�j���=Ϙ�>�R⽡�R>2��>#,ֽ�Т���Y�(/?�Ә�!:你�>(|�>e��R��>�ON?�	U��mG�D|;��˞����!��R >)�ھ!B��͖�����`��<jB�=���Z����;Dd��k��<��N���nY��61��4�<2�=�d<���=R���ޅ��A�= ���w¿*���ؽ`4��U�_�	��>C��:�:�Я�>=-I�M���g��y��>`��\�}=�t=��=���<z>�P-�<0��= U���/Ľ���<�ⴽ��`����`��+�<���e뮽y�	��$)�9��'J����什V���/��Q���Ѽ=̽�=I��@h
=��ϰ�����=�Cս-HA����=Kl���������̩i=K&,�U���n�u>�8�=��мj荾'���o��3%�;����Ȯ>/6O����>��k?�R?�� �n�A=�oh��·=5�=>t�)�.�W>��>X y�J�ܼ�?3�ɠV?�����]B�D,������N���ƾ"�l�Â�>"�!�(�>��(��B��Q;� RE��cܻ�Ϟ�|j��m>=���;@�C��8�(�o<�Q	=�T#�������}�|�V=4T���νI�6��ğ���(=�=��R=x�ݼ�̃=��J��7I<���C���6��u{3��z���+���N��9�� ��;0@��-Z�=�i�=ҙ<�4;�F����Q�ɻ�j�� �O� �x���������^/�F��>�pU��Uѿ������M�v�N��L�>��$�G�0���B���t�8bD��PU�����݆R=�e��.E�E�{��C義�?�+����I�o��l��#������!�t?R�.�,#��U=�!3վ|�L�:�8��oB����w��򻾥�*>�>8�<��M?�y?�Q�;�D�����76��,M��⤽1�@��W+�õ^>o�=u�-)b��@�?N�>��	�A�Ѿ��ｇY�>�W�<uQ�=+u7>���
�'��͕��޻�>�ݾ�,о�mھ'��C�ʾg׽4y��3��q��:��� ��Kx�BC���%�>Ȇ���G�z�޾�޽�KUӾ������þ�"�7M��(�]��
���9�4Y���]d��t轤�ݽUʋ��9�?~�=@���
��ii�c]e�I�X���?��4���%�2�U=_�>����I��@���}ȽK�q��%��(�5��7��Q`���p�[�a�`ɾ���j�2���������>pI2��;�~�<.�I��p1�1�d=7����0��>2��~�|zj>�I3�
9���B���E?��𽼾�O�v��<І~�Oځ�{�m=&����������<P�����<��>@}��<t���:�� 3=B�>X��s�=�l	�O�>�⻽yE�6�=��=�8�����C����X;iA)�+���1�=\�3�������T��7�<��=���h꺼�p��h��=�t�$'y=s����!��E�"��� �"��<�uv=�翙m0�/�$>A��W̌�b�6��)�=�G�eO�"ȓ<};]��F���>^"K��`����ҿ�����Ɂ�����Zw�䋀=��7��>��g݃��M�ȗ�?�a����V���m�j�;���U>���=��?�8�_���4�=���۫
�_2	�86ܽl{j=�ߐ;S���ӏ=lY�_x��a�l�' ���}��W�=�߸�q�4�>�������_��=��Ľ�_�yؼe��B�3����"�=����X�+�j�(����I��b<3��;�	-=ʜ�����<P;����=����=��>*Ͱ�o�^�p'뽉|�>��=w�Ž�;���z�=�=��:?��A�j�z�ܤm����+����ۼ�O*=֔*<&QP���6��q�=+呼�����>�̼�뜖�j�)?�8�=��=Ү>W������㦾J/����>I_u����=XXo�2S�;�9��=�?��+Hнb�z�2��=Q��	�"r���ӭ�S���>9��X>Fa��J��= .�=�I:�G�p��d�Z<i�M��./� �PE8=�#��c�� ����� �=�G��|�����쪼��|�n�<��� �= ��<���|C�=�-S������yl=o�=�Iq�\�=���=f9+���Q�K�)���g��=ʂ��厽���r��������?�=g
�=����e����Ƒ�=��6�����7>fR���Aͼ	��>�����o��Rߏ�܊��-�����=�g��V�-�#/ݽ�M�=&�;=�>�룽RH��T�9���y<�p,�f?�FrŽ��G�i�=,�&=8��<�_���W >��μ�9#��W��=�Q޽�eƼ�1��s�=���=EOm<ȄM��V½2��W��(��<��.����=Ds�=фƾh��=�>
Q;� �j�Կ�t�=��Ӽ5ɼ���<�-�8)��O2��d�8>�5�F����5��5ؾo�<ؼFD�>V
�=��%����ſ	�.<������͊Q���¾�G�=���;�A.>��^?QЩ>ɇ�=�5;�N�W}�����fy?�(��XZ�sO$>p�=���g���'­�~�x����:��G��'�����=���XeB���`���v���v��߽�uD>O\�h�K=�������oM=3���M��5<!��^oJ�������>�<��a=	�|���x��g�>tF��Tƾ���г�9F�3����p�ٽq�v��@1��
�Ie�ǖ�>��􃐽 5��8&�<	4�>��z'�L���J���j��>�A��۽b�/�-?c��҇��z��T�=��m�l;�=�W�=��;"a����	;�qv<�l=��ɽC.������Ka���̽%&>��������|��f/����=|m<�mG��t�
}ҽ��U=���UJ=�#�>�2�=����a������E�d���#��������6>�|F�R�<�7�-BE�|�b=օ=�Ó;t�>;s۽�Խ܀r������m��eʀ�d]
��mz���>�����岽���(>�����p�ij=�9>�+�=��������An��k)�=�P�s᳿R,[���þ����SԄ�'��=0������6ȿ�pm=f�q���e.���dX��m��3�>I��'�>�q��k�����*?�\��W�;b���2:>P>/��<Iߐ>��Q>�q�T=�S{����>���h����*�>;�<\87>N� ���,��(��uC�΄c=1f�=࠾>C�K�֟ = J��z���5���~�<3ci��p��C>#�=��n=� 3?��?��m�[x�=�z��(���v�i
���>r�h>�5���=�l���0�D����F>�>w1��$&�fң=�W�h7�"����uQ���>�J->�D=��5�`]Y>�:$��M?�ҝ�\E4=}��>���>6�3>��iZ>��4?����=�?�k��}R�E����n�x����*=¡���Y�1b�v\=���?7^�>�r�<�D�<�u�х���l�S��>��`�A�i=?b?7�^�&m>��w����u=��F�q�ƽ��>2V-�k��=+49>�J��X�%���:�fv.>8��<�R�Λ%>U�M=г>��<>��(>V�D�ѓi=fzF������3�q2�K�#�b����ϾCr��p�-�PR���X>S�,H_�g�\�o�ݽ�Q�>V޿>@��ܩ�E ��DC�b򢾏c�xQq�TT->h�(�\���<R�>�`q?�/����� �>T�J����?�
I?�:6��޾s�ھ>�����������������G<X�n�����	W�µ`?h�5>���ʷ�Հ����.>��?���ԹѸ�I1>�Bu�'Ƀ�0Ҿoy���>,uT�p>w�U=��>z�žOl���C��>@�3�K4�?�o�?p G>��t$N�5��<$?���k?cd�>��@>@Y�$fU>��L���<i:�=t:�> o�>�Fp=$έ�~��<+;��v���N>��m�J����>g�>/~<��E�=C5�=�m?"<��]O�1��>���>� ���%�<HzL=�O?���<��d�ΏE�X]�AW�>7�;��>*��=C	��m��Æ�66=="��ڀ�&�0�`���ԇ	������x���R>\������?��?�a->@�3��+��)��:�н��!����������޼���=L�x�Y�=��?�/�>�N�<wU���<�X�>���� 1>J��>���\�����U7�*0����q>0g9>��\�BCֽ!1Q��-��m3�r
:=q�� ��?EL>�)4��Ý�_k�>���}��P>���=2��>�>�K ��w�>���`_���K>��l>?e?�츾���=9Et>E���K��18�!��r}��.=��=��<�|q��z��ds���=��<������C�����>KO�<����9�ѽ��=�9O>x?n٬=ZJQ>��2��&��?�Ng��	�;�aM>�}�>�Y�p)0>�����>�����N��t�5��>B���Z!�6��?#�=g�	�Qk5�W�1�N����$V�q0Ͼ{T����4=s�a�7��,����ﭾSb�@f���2��)�<��>C�?�Rp?�G�=�Bh���ֿecz��כ�;E������_}4��>F�"<Ԑο�x����?���w��3����ݼ��?\�Ӿ�^�~�>)DM���t�w�?ؑ��U�$�]��y2�ـ��QA^�(cĽ��;�c�������,��/�쬄���@���?8�>K����*;>���~���p�N����e�o�pQٽ�������;;{��/�3>�:�@��P���lĽ֊����>��n��$��R���@��;����WK2�(��[�=���ܽ����(>9C�P�<�zҽ&���$�=�"q�ͺ�;�>��Ի�$��|��=؈�<OJ>��n�VPν�S�<��{��<ض�ފ�����>�D��G�=J���F\�=*���K�%=	���K�=�j �(�f�z.�=��=T����<E�=d�C����1*�ާ���W���<�콅A�=�����(��\��U�r�\��|�<�
���|��U -�8ս����V"ڽ�k�=꫁�>2��Q� �T��=�(��C� � =�y�<�)�)��5W��(=fj���Jh�(���9�J�����N�